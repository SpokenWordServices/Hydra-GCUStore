require 'spec_helper'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe CatalogController do
  
  it "should be restful at hull" do
    {:get=>"/"}.should route_to(:controller=>'catalog', :action=>'index')
    {:get=>'/catalog'}.should route_to(:controller=>'catalog', :action=>'index') 
    {:get=>'/catalog/_PID_'}.should route_to(:controller=>'catalog', :action=>'show', :id=>"_PID_") 
    {:get=>'/catalog/_PID_/edit'}.should route_to(:controller=>'catalog', :action=>'edit', :id=>"_PID_") 
  end

  
  describe "show" do
    describe "access controls" do
      it "should deny access to documents if role does not have permissions" do
        user = User.new(:login=>"Mr. Notallowed")
        sign_in user
        get :show, :id=>"hull:3374"
        response.should redirect_to("http://test.host/")
        flash[:notice].should == "You do not have sufficient access privileges to read this document, which has been marked private."
      end
      it "should allow access to documents if role has permissions" do
        user = User.new(:login=> "contentAccessTeam1")
        sign_in user
        get :show, :id=>"hull:3374"
        response.should be_success
      end
    end
  end

  describe "facet" do
    it "should return facet counts with permissions" do
      user = User.new(:login=> "contentAccessTeam1")
      sign_in user
      get :facet, :id=>'object_type_facet'
      response.should be_success
      assigns[:pagination].should_not be_nil
      assigns[:extra_controller_params][:q].should include "(_query_:\"edit_access_group_t:public\" OR _query_:\"discover_access_group_t:public\" OR _query_:\"read_access_group_t:public\" OR _query_:\"edit_access_group_t:contentAccessTeam\" OR _query_:\"discover_access_group_t:contentAccessTeam\" OR _query_:\"read_access_group_t:contentAccessTeam\" OR _query_:\"edit_access_person_t:contentAccessTeam1\" OR _query_:\"discover_access_person_t:contentAccessTeam1\" OR _query_:\"read_access_person_t:contentAccessTeam1\")"
    end
  end
    

  
  
end
