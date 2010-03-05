require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe DocumentsController do
  
  before do
    request.env['WEBAUTH_USER']='bob'
  end
  
  it "should use DocumentController" do
    controller.should be_an_instance_of(DocumentsController)
  end
  
  describe "update" do
    it "should update the object with the attributes provided, setting wau regardless of env" do
      mock_document = mock("document")
      mock_document.expects(:update_indexed_attributes).returns({"subject"=>{"2"=>"My Topic"}})
      mock_document.expects(:save)
      Document.expects(:find).with("_PID_").returns(mock_document)
      put :update, :id=>"_PID_", "document"=>{"subject"=>{"-1"=>"My Topic"}}, :wau => 'krang'
      session[:user].should == 'krang'
    end
    it "should update the object with the attributes provided" do
      mock_document = mock("document")
      mock_document.expects(:update_indexed_attributes).returns({"subject"=>{"2"=>"My Topic"}})
      mock_document.expects(:save)
      Document.expects(:find).with("_PID_").returns(mock_document)
      put :update, :id=>"_PID_", "document"=>{"subject"=>{"-1"=>"My Topic"}}
      #session[:user].should == 'bob'
    end
    it "should initialize solr" do
      pending
      ActiveFedora::SolrService.expects(:register)
      Document.expects(:find).with("_PID_").returns(stub_everything)
      put :update, :id=>"_PID_", "basic_asset"=>{"subject"=>{"-1"=>"My Topic"}}
      session[:user].should == 'bob'
    end
    it "should render the right template" do

    end
  end
end
