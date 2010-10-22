require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe HydrangeaDataset do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @dataset = HydrangeaDataset.new
  end
  
  describe "insert_grant" do
    it "should generate a new grant into the current xml, treating strings and symbols equally to indicate type, and then mark the datastream as dirty" do
      dataset_ds = @dataset.datastreams_in_memory["hydraDataset"]
      dataset_ds.expects(:insert_grant)
      node, index = @dataset.datastreams_in_memory["hydraDataset"].insert_grant
    end
  end
  
  describe "remove_grant" do
    it "should remove the corresponding grant from the xml and then mark the datastream as dirty" do
      dataset_ds = @dataset.datastreams_in_memory["hydraDataset"]
      dataset_ds.expects(:remove_grant).with("3")
      node, index = @dataset.datastreams_in_memory["hydraDataset"].remove_grant("3")
    end
  end

end