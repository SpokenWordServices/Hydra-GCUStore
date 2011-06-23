require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GrantNumbersController do
  
  describe "create" do
    it "should support adding new grant number nodes" do
      pending # TODO: fix route
      mock_document = mock("document")
      mock_document.expects(:insert_grant_number).returns(["foo node","989"])
      mock_document.expects(:save)
      UketdObject.expects(:find).with("_PID_").returns(mock_document)
      post :create, :asset_id=>"_PID_", :controller => "grant_numbers", :content_type => "uketd_object"
      response.should redirect_to "http://test.host/resources/_PID_/edit"
    end
  end
  
  describe "destroy" do
    it "should delete the grant_number corresponding to index" do
      pending # TODO: fix route
      mock_document = mock("UketdObject")
      mock_document.expects(:remove_grant_number).with("3")
      mock_document.expects(:save)
      JournalArticle.expects(:find).with("_PID_").returns(mock_document)
      
      delete :destroy, :asset_id=>"_PID_", :content_type => "uketd_object", :index=>"3"
    end
  end
  
end
