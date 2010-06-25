require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe AssetsController do
  
  before do
    request.env['WEBAUTH_USER']='bob'
  end
  
  it "should use DocumentController" do
    controller.should be_an_instance_of(AssetsController)
  end
  
  describe "update" do
    it "should update the object with the attributes provided" do
      mock_document = mock("document")
      HydrangeaArticle.expects(:find).with("_PID_").returns(mock_document)
      
      mock_document.expects(:update_indexed_attributes).with({"subject"=>{"-1"=>"My Topic"}}, {}).returns({"subject"=>{"2"=>"My Topic"}})
      mock_document.expects(:save)
      put :update, :id=>"_PID_", "asset"=>{"subject"=>{"-1"=>"My Topic"}}
      #session[:user].should == 'bob'
    end
    it "should support updating OM::XML datastreams" do
      mock_document = mock("document")
      HydrangeaArticle.expects(:find).with("_PID_").returns(mock_document)
      
      update_method_args = [ {:parent_select=>[{:person=>0}, :last_name], :child_index=>0, :values=>"Sample New Value"}, {:datastreams=>"descMetadata"} ]
      mock_document.expects(:update_indexed_attributes).with( *update_method_args ).returns({"person_0_last_name"=>{"0"=>"Sample New Value"}})
      mock_document.expects(:save)
      put :update, :id=>"_PID_", "content_type"=>"hydrangea_article", "datastream"=>"descMetadata", "field_name"=>"person_0_last_name","parent_select"=>[{":person"=>"0"}, ":last_name"], "child_index"=>"0", "value"=>"Sample New Value"
    end
    it "should initialize solr" do
      pending
      ActiveFedora::SolrService.expects(:register)
      SaltDocument.expects(:find).with("_PID_").returns(stub_everything)
      put :update, :id=>"_PID_", "asset"=>{"subject"=>{"-1"=>"My Topic"}}
      session[:user].should == 'bob'
    end
  end
  
end
