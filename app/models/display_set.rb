require "hydra"
require 'tree'

class DisplaySet < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :label=>"MODS metadata", :type => ModsDisplaySet

  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  # A place to put extra metadata values
  has_metadata :name => "properties", :label=>" Workflow properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def title
    datastreams["descMetadata"].term_values(:title).first
  end

  def self.tree
    sets = build_array_of_parents_and_children
    root_node = build_children(Tree::TreeNode.new("Root set", "info:fedora/hull:rootDisplaySet"), sets)
  end

  def self.parent_graph
    set = DisplaySet.display_sets
    pids = set.map{|s| "info:fedora/"+s["id"]}
    Hash[*(set.map {|s| ["info:fedora/#{s['id']}", {:parent=>parent_pid(s, pids), :pid=>s["id"], :title=>s["title_t"]}]}).flatten]
  end


  private

  def self.parent_pid(node, pids)
    node["is_member_of_s"] ? (node["is_member_of_s"] & pids).first : nil
  end

  def self.build_array_of_parents_and_children
    hits = display_sets
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

  def self.display_sets
    fields = "has_model_s:info\\:fedora/hull-cModel\\:displaySet"
    options = {:field_list=>["id", "id_t", "title_t", "is_member_of_s"], :rows=>10000, :sort=>[{"system_create_dt"=>:ascending}]}
    ActiveFedora::SolrService.instance.conn.query(fields,options).hits
  end

  def self.display_set_pids
    display_sets.map {|hit| "info:fedora/#{hit["id_t"]}" }
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
  def options_for_nested_select(args ={},level=0)
    args[:options] ||= []
    if is_root?
      pad = ''
    else
      pad = ('-' * (level - 1) * 2) + '--'
    end

    args[:options] <<  ["#{pad}#{name}", "#{content}"] unless content == args[:exclude]

    children { |child| child.options_for_nested_select(args,level + 1)}

    args[:options]
  end

  def unordered_list(options=[],level=0)
    
  end
end
