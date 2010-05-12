require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HydraAccessControlsHelper do
  
  describe "editor?" do
    it "should return true if the session[:user] is an editor or an archivist" do
      mock_user = mock("User", :login=>"archivist1")
      helper.stubs(:current_user).returns(mock_user)
      helper.editor?.should be_true
    end
    
    it "should return false if the session[:user] is not logged in" do
      helper.stubs(:current_user).returns(nil)
      helper.editor?.should be_false
    end
    it "should return false if the session[:user] does not have an editor role" do
      mock_user = mock("User", :login=>"nobody_special")
      helper.stubs(:current_user).returns(mock_user)
      helper.editor?.should be_false
    end
  end
  
end