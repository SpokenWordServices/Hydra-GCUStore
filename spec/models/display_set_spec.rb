require 'spec_helper'

describe DisplaySet do

  describe "default tree" do
    it "should have a root node" do
      root_node = DisplaySet.tree
      root_node.should be_kind_of(Tree::TreeNode)
      root_node.children.size.should == 1 
      root_node.children.first.content.should == "info:fedora/hull:700"
      root_node.print_tree
    end
  end

  describe "tree with nodes" do
    it "should do provide a set of options for a fedora_select nested select" do
      options = DisplaySet.tree.options_for_nested_select
      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end
  end

end
