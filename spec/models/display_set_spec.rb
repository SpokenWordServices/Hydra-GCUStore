require 'spec_helper'

describe DisplaySet do

  describe "default tree" do
    it "should have a root node" do
      root_node = DisplaySet.tree
      root_node.should be_kind_of(Tree::TreeNode)
      root_node.children.size.should >= 1 
      root_node.children.first.content.should == "info:fedora/hull:700"
      root_node.print_tree
    end
  end

  describe "adding a node" do
    before do
      @node = DisplaySet.new
      @node.datastreams['descMetadata'].update_indexed_attributes({[:title] => 'Blue sky'})
      @node.add_relationship(:is_member_of, 'hull:700')
      @node.save
    end
    it "should be in the tree" do
      root_node = DisplaySet.tree
      root_node.children.first.children.should_not be_empty
      root_node.children.first.children.map{|c| c.content.split('/')[1]}.should include @node.pid
    end
    after do
      @node.delete
    end
    
  end

  describe "tree with nodes" do
    it "should do provide a set of options for a fedora_select nested select" do
      options = DisplaySet.tree.options_for_nested_select
      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end
  end

  describe "an instance" do
    before do
      @node = DisplaySet.new
      @node.datastreams['descMetadata'].update_indexed_attributes({[:title] => 'Blue sky'})
      @node.add_relationship(:is_member_of, 'hull:700')
      @node.save
    end
    it "should have a display_set property" do
      @node.display_set.should == 'info:fedora/hull:700'
      @node.structural_set.should be_nil
    end
    it "should have a top_level_collection property" do
      @node.top_level_collection.should == {:title=>["Postgraduate Medical Institute"], :pid=>"hull:700", :parent=>"info:fedora/hull:rootDisplaySet"}
    end
    it "should have a title" do
      @node.title.should == 'Blue sky'
    end
    after do
      @node.delete
    end
    
  end

end
