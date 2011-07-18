require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"
require 'tree'
require 'pp'

describe StructuralSet do
  it "should return a tree" do
    root_node = StructuralSet.tree
    root_node.print_tree


    puts "Attempting to get options for select"
    options = root_node.options_for_nested_select

    options.each {|v| puts "#{v[0]} = #{v[1]}" }
  end
  
  it "should do provide a set of options for a fedora_select nested select" do
    options = StructuralSet.tree.options_for_nested_select
    options.each {|v| puts "#{v[0]} = #{v[1]}" }
  end

end
