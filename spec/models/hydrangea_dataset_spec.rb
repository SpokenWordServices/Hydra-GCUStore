require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe HydrangeaDataset do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @dataset = HydrangeaDataset.new
  end
  
  describe "insert_grant" do
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type, and then mark the datastream as dirty" do
      dataset_ds = @dataset.datastreams_in_memory["hydraDataset"]
      dataset_ds.expects(:insert_grant)
      node, index = @dataset.insert_grant
    end
  end
  
  describe "remove_grant" do
    it "should remove the corresponding grant from the xml and then mark the datastream as dirty" do
      pending
      dataset_ds = @dataset.datastreams_in_memory["hydraDataset"]
      dataset_ds.expects(:remove_grant).with("person","3")
      node, index = @dataset.remove_grant("person", "3")
    end
  end
  
  describe "apply_depositor_metadata" do
    it "should set depositor info in the properties and rightsMetadata datastreams" do
      rights_ds = @dataset.datastreams_in_memory["rightsMetadata"]
      prop_ds = @dataset.datastreams_in_memory["properties"]

      node, index = @dataset.apply_depositor_metadata("Depositor Name")
      
      prop_ds.depositor_values.should == ["Depositor Name"]
      rights_ds.get_values([:edit_access, :person]).should == ["Depositor Name"]
    end
  end
end