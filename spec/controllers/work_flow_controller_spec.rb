require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WorkFlowController do

  it "should be restful" do
    route_for(:controller=>'work_flow', :action=>'update', :id=>"3", :content_type=>"article",:workflow_step=>"qa").should == { :method => 'put', :path => '/work_flow/article/3/qa' }

    params_from(:put, '/work_flow/article/3/qa').should == {:controller=>'work_flow', :action=>'update', :id=>'3',:workflow_step=>"qa",:content_type=>"article"}
  end
 


  describe "update" do
    it "should move the object from one queue to another" do
      pending
      mock_document = mock("document")
      mock_document.expects(:change_queue_membership).with(:qa).returns(true)
      controller.expects(:load_document_from_params).returns(mock_document)
      
      
      put :update, :id=>"_PID_", :content_type=>"content",:workflow_step =>"qa",:method => :put
    end
  end
end
