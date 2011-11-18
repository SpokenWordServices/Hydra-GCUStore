require 'spec_helper'

describe WorkFlowController do

  it "should be restful" do
    { :get => '/work_flow/new' }.should route_to(:controller=>'work_flow', :action=>'new')
    { :post => '/work_flow/article/3/qa' }.should route_to(:controller=>'work_flow', :action=>'update', :id=>"3", :content_type=>"article",:workflow_step=>"qa")
  end
 


  describe "update" do
    it "should move the object from one queue to another" do
      mock_document = mock("document",  :pid=>'_PID_')
      mock_document.expects(:change_queue_membership).with(:qa).returns(true)
      mock_document.expects :save
      controller.expects(:load_document_from_params).returns(mock_document)
      
      
      post :update, :id=>"_PID_", :content_type=>"content",:workflow_step =>"qa",:method => :put
    end
  end

	describe "new" do
		it "should enforce create permissions, redirecting to show index and resetting session context if user does not have create permissions" do
      sign_in FactoryGirl.find_or_create(:student1) 

			get :new
			response.should redirect_to root_path
		end
  	it "should render normally if user has create permissions" do
      sign_in FactoryGirl.find_or_create(:cat) 
    
		  get :new
      response.should_not redirect_to(:controller => 'catalog', :action => 'index')
    end
		
	end
end
