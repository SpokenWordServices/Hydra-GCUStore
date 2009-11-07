require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
# cucumber --tags @edit
# or
# rake cucumber

describe DocumentsController do
  
  before do
    #controller.stubs(:protect_from_forgery).returns("meh")
    session[:user]='bob'
  end
  
  it "should use DocumentController" do
    controller.should be_an_instance_of(DocumentsController)
  end
  
  describe "update" do
    it "should update the object with the attributes provided" do
      mock_document = mock("document")
      mock_document.expects(:update_indexed_attributes)
      mock_document.expects(:save)
      Document.expects(:find).with("_PID_").returns(mock_document)
      put :update, :id=>"_PID_", "document"=>{"subject"=>{"-1"=>"My Topic"}}
    end
    it "should initialize solr" do
      pending
      ActiveFedora::SolrService.expects(:register)
      Document.expects(:find).with("_PID_").returns(stub_everything)
      put :update, :id=>"_PID_", "basic_asset"=>{"subject"=>{"-1"=>"My Topic"}}
    end
  end
end