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

  describe "a saved instance" do
    before do
      # @apo = mock("APO", :defaultObjectMetadata=>Hydra::RightsMetadata.new)
      # ActiveFedora::Base.expects(:find).with('hull-apo:structuralSet').returns(@apo)
      @instance = StructuralSet.new
      @instance.save
      @instance = StructuralSet.find(@instance.pid)
    end
    it "should have defaultObjectRights datastream" do
      @instance.defaultObjectRights.content.should == '
<rightsMetadata xmlns="http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1">
  <copyright>
    <human></human>
    <machine></machine>
  </copyright>
  <access type="discover">
    <human></human>
    <machine>
      <group>contentAccessTeam</group>
    </machine>
  </access>
  <access type="read">
    <human></human>
    <machine>
      <group>contentAccessTeam</group>
    </machine>
  </access>
  <access type="edit">
    <human></human>
    <machine>
      <group>contentAccessTeam</group>
    </machine>
  </access>
  <use>
    <human></human>
    <machine></machine>
  </use>
  <embargo>
    <human></human>
    <machine></machine>
  </embargo>
</rightsMetadata>
'
    end
    it "should be governedBy " do
      @instance.is_governed_by.should == ["info:fedora/hull-apo:structuralSet"]
    end
  end

end
