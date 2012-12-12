require 'spec_helper'
require 'user_helper'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe LicencesController do 

  describe "new" do 
    include UserHelper
    it "should check permissions" do
      controller.expects(:enforce_create_permissions)
      get :new
    end

  end

  describe "create" do 
    dummy_licence=Licence.new(:name =>"dummy") 
    it "should check permissions" do
      controller.expects(:enforce_create_permissions)
      post :create, :licence=> dummy_licence
      response.should redirect_to licences_path
    end

  end

  describe "update" do 
    saved_licence=Licence.create(:name=>"saved licence")
    it "should check permissions" do
      controller.expects(:enforce_create_permissions)
      post :update, :id=> saved_licence.id, :licence=> saved_licence
    end

  end

  describe "destroy" do 
    saved_licence=Licence.create(:name=>"saved licence")
    it "should check permissions" do
      controller.expects(:enforce_create_permissions)
      post :destroy, :id=> saved_licence.id
      response.should redirect_to licences_path
    end

  end


end
