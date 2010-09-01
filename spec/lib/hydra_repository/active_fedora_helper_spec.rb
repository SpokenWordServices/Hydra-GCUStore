require File.expand_path( File.join( File.dirname(__FILE__), '..','..','spec_helper') )
require "hydra"
class FakeAssetsController
  include MediaShelf::ActiveFedoraHelper
end

def helper
  @fake_controller
end

describe MediaShelf::ActiveFedoraHelper do

  before(:all) do
    @fake_controller = FakeAssetsController.new
  end
  
  describe "retrieve_af_model" do
    it "should return a Model class if the named model has been defined" do
      result = helper.retrieve_af_model("file_asset")
      result.should == FileAsset
      result.superclass.should == ActiveFedora::Base
      result.included_modules.should include(ActiveFedora::Model) 
    end
    it "should accept camel cased OR underscored model name"  
  end
  
end