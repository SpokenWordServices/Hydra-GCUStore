require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MultiFieldController do
  
  describe "create" do
    it "should support adding new multi-field node" do
      mock_new_node = mock("ins_node")
      mock_new_node.expects("inner_html=").returns(true)
      
      mock_node = mock("node")
      mock_node.expects(:inner_html).returns("999")
      
      mock_ds = mock("ds") 
      mock_ds.expects(:find_by_terms).with(:rights).returns([mock_node])

      mock_document = mock("document")
      mock_document.expects(:insert_rights).returns([mock_new_node,"989"])
      mock_document.expects(:datastreams).returns({"descMetadata"=>mock_ds})
      mock_document.expects(:save)
      @controller.expects(:load_document_from_id).with("_PID_").returns(mock_document)

      post :create, :asset_id=>"_PID_", :controller => "multi_field", :content_type => "generic_content", :datastream_name=>"descMetadata", :fields=>[:rights], :asset=>{"descMetadata"=>{"rights"=>{"0"=>"(c) University of Hull. All rights reserved."}}}
      response.should redirect_to "http://test.host/resources/_PID_/edit"
    end

    it "should support  updating the first multi-field node if it is empty" do
      mock_node = mock("node")
      mock_node.expects(:inner_html).returns("")
      
      mock_ds = mock("ds") 
      mock_ds.expects(:find_by_terms).with(:rights).returns([mock_node])
      mock_ds.expects(:update_indexed_attributes).with({[{:rights =>"0"}]=>"(c) The Author, All rights reserved"})

      mock_document = mock("document")
      mock_document.expects(:datastreams).at_least_once.returns({"descMetadata"=>mock_ds})
      mock_document.expects(:save)
     	@controller.expects(:load_document_from_id).with("_PID_").returns(mock_document)

      post :create, :asset_id=>"_PID_", :controller => "multi_field", :content_type => "multi_field", :datastream_name=>"descMetadata", :fields=>[:rights], :asset=>{"descMetadata"=>{"rights"=>{"0"=>"(c) The Author, All rights reserved"}}}
      response.should redirect_to "http://test.host/resources/_PID_/edit"
    end

  end

  describe "new" do
    it "should generate an empty form" do
      mock_ds = mock("ds") 
      mock_ds.expects(:find_by_terms).with(:rights).returns(["node1"])

      mock_document = mock("document")
      mock_document.expects(:datastreams).returns({"descMetadata"=>mock_ds})
      mock_document.stubs(:pid).returns("_PID_")
      @controller.expects(:load_document_from_id).with("_PID_").returns(mock_document)
      get :new, :asset_id=>"_PID_", :content_type=>"generic_content", :fields=>[:rights], :datastream_name=>"descMetadata"
      assigns(:next_multi_field_index) == 1
      assigns(:document_fedora) == mock_document
      assigns(:content_type) == "generic_content"
    end
    
  end 


  describe "destroy" do
    it "should delete the grant_number corresponding to index" do
      pending # TODO: fix route
      mock_document = mock("GenericContent")
      mock_document.expects(:remove_rights).with("3")
      mock_document.expects(:save)
      @controller.expects(:load_document_from_id).with("_PID_").returns(mock_document)
      
      delete :destroy, :asset_id=>"_PID_", :content_type => "generic_content", :index=>"3"
    end
  end
  
end
