require "hydra"
require 'tree'

class StructuralSet < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods
  include ActiveFedora::Relationships

  def initialize(attrs=nil)
    super(attrs)
    if new_object?
      self.add_relationship(:has_model,"info:fedora/hydra-cModel:commonMetadata")
    end
  end

	#We want the RELS-EXT to be X and have label
  self.ds_specs = {'RELS-EXT'=> {:type=> ActiveFedora::RelsExtDatastream, :label=>"Fedora Object-to-Object Relationship Metadata", :control_group=>'X', :block=>nil}}

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => RightsMetadata  

  has_metadata :name => "defaultObjectRights", :label=>"Default object rights", :type => NonindexingRightsMetadata 

  has_metadata :name => "descMetadata", :label=>"MODS metadata", :type => ModsStructuralSet, :control_group => "M"

  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  # A place to put extra metadata values
  has_metadata :name => "properties", :label=>"Workflow properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def self.tree

    hits = retrieve_structural_sets

    sets = build_array_of_parents_and_children(hits)

    root_node = build_children(Tree::TreeNode.new("Root set", "info:fedora/hull:rootSet"), sets)
  end

  def after_create
    apo = ActiveFedora::Base.find("hull-apo:structuralSet")
    raise "Unable to find hull-apo:structuralSet" unless apo
    add_relationship :is_governed_by, apo
    copy_rights_metadata(apo)
  end

  def copy_default_object_rights(parent_pid)
    parent = StructuralSet.find(parent_pid)
    defaultRights = Hydra::RightsMetadata.new(self.inner_object, 'defaultObjectRights')
    Hydra::RightsMetadata.from_xml(parent.defaultObjectRights.content, defaultRights)
	  datastreams["defaultObjectRights"] = defaultRights if datastreams.has_key? "defaultObjectRights"
  end

  #
  # Adds metadata about the depositor to the asset
  # Most important behavior: if the asset has a rightsMetadata datastream, this method will add +depositor_id+ to its individual edit permissions.
  #
  def apply_depositor_metadata(depositor_id)
    prop_ds = self.datastreams["properties"]
    rights_ds = self.datastreams["rightsMetadata"]
  
    if !prop_ds.nil? && prop_ds.respond_to?(:depositor_values)
      prop_ds.depositor_values = depositor_id unless prop_ds.nil?
    end
	  return true
  end


  private

  def self.retrieve_structural_sets
    fields = "has_model_s:info\\:fedora/hull-cModel\\:structuralSet"
    options = {:field_list=>["id", "id_t", "title_t", "is_member_of_s"], :rows=>10000, :sort=>[{"system_create_dt"=>:ascending}]}
    ActiveFedora::SolrService.instance.conn.query(fields,options).hits
  end

  def self.structural_set_pids
    retrieve_structural_sets.map {|hit| "info:fedora/#{hit["id_t"]}" }
  end
  
  def self.build_array_of_parents_and_children hits
    pids = hits.map {|hit| "info:fedora/#{hit["id_t"]}" }
    sets = hits.each.inject({}) do |hash,hit|
      if  hit["id_t"].first  != "hull:rootSet"
        parent_pid = hit["is_member_of_s"].first if hit.fetch("is_member_of_s",nil)
        if parent_pid && pids.include?( parent_pid )
          hash[parent_pid] = {:children=>[]} unless hash[parent_pid]
          hash[parent_pid][:children] << hit
        end
      end
      hash
    end
  end

  def self.build_children node, nodes
    if nodes.fetch(node.content,nil)
      nodes[node.content][:children].each do |child|
        child_node = Tree::TreeNode.new(child["title_t"].first,"info:fedora/#{child["id_t"].first}")
        node << build_children(child_node, nodes)
      end
    end
    node
  end



end

class Tree::TreeNode
  def options_for_nested_select(options=[],level=0)
    if is_root?
      pad = ''
    else
      pad = ('-' * (level - 1) * 2) + '--'
    end

    options <<  ["#{pad}#{name}", "#{content}"]
		
		#Sort the children - defaults on name sort
	  children.sort! if !children.nil?	

    children { |child| child.options_for_nested_select(options,level + 1)}

    options
  end

  def unordered_list(options=[],level=0)
    
  end
end
