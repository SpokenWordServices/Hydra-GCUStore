require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe CatalogController do
  
  before do
    #request.env['WEBAUTH_USER']='bob'
  end

  describe "show" do
    it "should redirect to edit view if session is in edit context and user has edit permission" do
      request.env["WEBAUTH_USER"]="francis"
      controller.session[:viewing_context] = "edit"
      get(:show, {:id=>"druid:fs442rd9742"})
      response.should redirect_to(:action => 'edit')
    end
    it "should allow you to reset the session context to browse using :viewing_context param" do
      request.env["WEBAUTH_USER"]="francis"
      controller.session[:viewing_context] = "edit"
      get(:show, :id=>"druid:fs442rd9742", :viewing_context=>"browse")
      session[:viewing_context].should == "browse"
      response.should_not redirect_to(:action => 'edit')
    end
    
    it "should quietly switch session state to browse if user does not have edit permissions" do
      request.env["WEBAUTH_USER"]="Ronald McDonald"
      controller.session[:viewing_context] = "edit"
      get(:show, {:id=>"druid:fs442rd9742"})
      session[:viewing_context].should == "browse"
      response.should_not redirect_to(:action => 'edit')
    end
  end
  
  describe "edit" do
    it "should enforce edit permissions, redirecting to show action and resetting session context if user does not have edit permissions" do
      request.env["WEBAUTH_USER"]="Mrs. Quang"
      get :edit, :id=>"druid:fs442rd9742"
      response.should redirect_to(:action => 'show')
      flash[:message].should == "You do not have sufficient privileges to edit this document."
    end
    it "should render normally if user has edit permissions" do
      request.env["WEBAUTH_USER"]="alice"
      get :edit, :id=>"druid:fs442rd9742"
      response.should_not redirect_to(:action => 'show')
    end
  end
  
end
