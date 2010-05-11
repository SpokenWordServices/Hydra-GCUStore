require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HydraAccessControlsHelper


describe HydraAccessControlsHelper do
  
  describe "editor?" do
    it "should return true if the session[:user] is an editor or an archivist" do
      session[:user] = "francis"
      editor?.should be_true
    end
    
    it "should return false if the session[:user] is not logged in" do
      session[:user] = nil
      editor?.should be_false
    end
    it "should return false if the session[:user] does not have an editor role" do
      session[:user] = "Ronald McDonald"
      editor?.should be_false
    end
  end
  
end