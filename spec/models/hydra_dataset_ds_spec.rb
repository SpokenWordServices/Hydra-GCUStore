require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Hydra::ModsArticle do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @dataset_ds = HydraDatasetDs.new
  end

  describe "#grant_template" do
    it "should generate a new person node" do
      node = HydraDatasetDs.grant_template
      node.should be_kind_of(Nokogiri::XML::Element)
      node.to_xml.should == "<grant>\n  <organization/>\n  <number/>\n</grant>"
    end
  end
  
  describe "insert_contributor" do
    it "should generate a new grant into the current xml and mark the datastream as dirty" do
      @dataset_ds.find_by_terms(:grant).length.should == 1
      @dataset_ds.dirty?.should be_false
      node, index = @dataset_ds.insert_grant
      @dataset_ds.dirty?.should be_true
      
      @dataset_ds.find_by_terms(:grant).length.should == 2
      node.to_xml.should == HydraDatasetDs.grant_template.to_xml
      index.should == 1
      
      node, index = @dataset_ds.insert_grant
      @dataset_ds.find_by_terms(:grant).length.should == 3
      index.should == 2
    end
  end
  
  describe "remove_contributor" do
    it "should remove the corresponding contributor from the xml and then mark the datastream as dirty" do
      pending
      @dataset_ds.find_by_terms(:grant).length.should == 1
      result = @dataset_ds.remove_grant("person", "0")
      @dataset_ds.find_by_terms(:grant).length.should == 0
      @dataset_ds.should be_dirty
    end
  end
  
end