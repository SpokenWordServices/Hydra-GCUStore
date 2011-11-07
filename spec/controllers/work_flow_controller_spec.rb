require 'spec_helper'

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

	describe "new" do
		it "should enforce create permissions, redirecting to show index and resetting session context if user does not have create permissions" do
			mock_user = mock("User")
      mock_user.stubs(:login).returns("student1")
      mock_user.stubs(:is_being_superuser?).returns(false)
      controller.stubs(:current_user).returns(mock_user)

			get :new
			response.should redirect_to(:controller => 'catalog' ,:action => 'index')
		end
  	it "should render normally if user has create permissions" do
      mock_user = stub("User", :login=>"contentAccessTeam1")
      controller.stubs(:current_user).returns(mock_user)
    
		  get :new
      response.should_not redirect_to(:controller => 'catalog', :action => 'index')
    end
		
	end
end
