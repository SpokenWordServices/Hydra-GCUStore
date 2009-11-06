require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DocumentsController do
  
  before do
    #controller.stubs(:protect_from_forgery).returns("meh")
    session[:user]='bob'
  end
  
  it "should use DocumentController" do
    controller.should be_an_instance_of(DocumentsController)
  end
  
  describe "edit" do
  end
  
  describe "update" do
    it "should update the object with the attributes provided" do
      pending
      mock_basic_asset = mock("document")
      mock_basic_asset.expects(:update_indexed_attributes)
      mock_basic_asset.expects(:save)
      Document.expects(:find).with("_PID_").returns(mock_basic_asset)
      put :update, :id=>"_PID_", "basic_asset"=>{"subject"=>{"-1"=>"My Topic"}}
    end
    it "should initialize solr" do
      pending
      ActiveFedora::SolrService.expects(:register)
      Document.expects(:find).with("_PID_").returns(stub_everything)
      put :update, :id=>"_PID_", "basic_asset"=>{"subject"=>{"-1"=>"My Topic"}}
    end
  end
end