require "hydra"
require 'tree'

class DisplaySet < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => ModsDisplaySet

  has_metadata :name => "DC", :type => ObjectDc

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def self.tree
    hits = display_sets
    sets = build_array_of_parents_and_children(hits)
    root_node = build_children(Tree::TreeNode.new("Root set", "info:fedora/hull:rootDisplaySet"), sets)
  end

  private

  def self.display_sets
    fields = "has_model_s:info\\:fedora/hull-cModel\\:displaySet"
    options = {:field_list=>["id", "id_t", "title_t", "is_member_of_s"], :rows=>10000, :sort=>[{"system_create_dt"=>:ascending}]}
    ActiveFedora::SolrService.instance.conn.query(fields,options).hits
  end
  
  def self.build_array_of_parents_and_children hits
    pids = hits.map {|hit| "info:fedora/#{hit["id_t"]}" }
    sets = hits.each.inject({}) do |hash,hit|
      if  hit["id_t"].first  != "hull:rootDisplaySet"
        parent_pid = (pids & hit["is_member_of_s"]).first if hit.fetch("is_member_of_s",nil)
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