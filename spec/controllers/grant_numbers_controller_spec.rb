require 'spec_helper'

describe GrantNumbersController do
  
  describe "create" do
    it "should support adding new grant number nodes" do
      mock_new_node = mock("ins_node")
      mock_new_node.expects("inner_html=").returns(true)
      
      mock_node = mock("node")
      mock_node.expects(:inner_html).returns("999")
      
      mock_ds = mock("ds") 
      mock_ds.expects(:find_by_terms).with(:grant_number).returns([mock_node])

      mock_document = mock("document")
      mock_document.expects(:insert_grant_number).returns([mock_new_node,"989"])
      mock_document.expects(:datastreams).returns({"descMetadata"=>mock_ds})
      mock_document.expects(:save)
      UketdObject.expects(:find).with("_PID_").returns(mock_document)

      post :create, :asset_id=>"_PID_", :controller => "grant_numbers", :content_type => "uketd_object", :asset=>{"descMetadata"=>{"grant_number"=>{"0"=>"bbb888"}}}
      response.should redirect_to "http://test.host/resources/_PID_/edit"
    end

    it "should support adding updating the first grant number node if it is empty" do
      mock_node = mock("node")
      mock_node.expects(:inner_html).returns("")
      
      mock_ds = mock("ds") 
      mock_ds.expects(:find_by_terms).with(:grant_number).returns([mock_node])
      mock_ds.expects(:update_indexed_attributes).with({[{:grant_number =>"0"}]=>"bbb888"})

      mock_document = mock("document")
      mock_document.expects(:datastreams).at_least_once.returns({"descMetadata"=>mock_ds})
      mock_document.expects(:save)
      UketdObject.expects(:find).with("_PID_").returns(mock_document)

      post :create, :asset_id=>"_PID_", :controller => "grant_numbers", :content_type => "uketd_object", :asset=>{"descMetadata"=>{"grant_number"=>{"0"=>"bbb888"}}}
      response.should redirect_to "http://test.host/resources/_PID_/edit"
    end

  end

  describe "new" do
    it "should generate an empty form" do
      mock_ds = mock("ds") 
      mock_ds.expects(:find_by_terms).with(:grant_number).returns(["node1"])

      mock_document = mock("document")
      mock_document.expects(:datastreams).returns({"descMetadata"=>mock_ds})
      mock_document.stubs(:pid).returns("_PID_")
      UketdObject.expects(:find).with("_PID_").returns(mock_document)
      get :new, :asset_id=>"_PID_", :content_type=>"uketd_object"
      assigns(:next_grant_number_index) == 1
      assigns(:document_fedora) == mock_document
      assigns(:content_type) == "uketd_object"
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
