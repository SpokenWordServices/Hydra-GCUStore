require "hydra"
require 'tree'

class StructuralSet < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => ModsStructuralSet

  has_metadata :name => "DC", :type => ObjectDc

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def self.tree
    hits = retrieve_structural_sets

    sets = build_array_of_parents_and_children(hits)

    root_node = build_children(Tree::TreeNode.new("Root set", "info:fedora/hull:rootSet"), sets)
  end

  private

  def self.retrieve_structural_sets
    fields = {:has_model_s=>"info\:fedora/hull-cModel\:structuralSet"}
    options = {:rows=>10000, :field_list=> ["id","id_t","title_t","is_member_of_s"]}
    ActiveFedora::Base.find_by_fields_by_solr(fields, options).hits
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

    children { |child| child.options_for_nested_select(options,level + 1)}

    options
  end

  def unordered_list(options=[],level=0)
    
  end
end
