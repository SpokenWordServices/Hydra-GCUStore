require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hydra::ModelMethods do
  
  describe "apply_depositor_metadata" do
    it "should set the depositor metadata field and assign edit permissions to the given depositor_id" do
      prop_ds = mock("properties ds")
      rights_ds = mock("rights ds")
      prop_ds.expects(:respond_to?).with(:depositor_values).returns(true)
      prop_ds.expects(:depositor_values=).with("foouser")
      rights_ds.expects(:update_indexed_attributes).with([:edit_access, :person]=>"foouser")

      helper.stubs(:datastreams_in_memory).returns({"rightsMetadata"=>rights_ds,"properties"=>prop_ds})
      helper.apply_depositor_metadata("foouser")
    end
  end
  
end