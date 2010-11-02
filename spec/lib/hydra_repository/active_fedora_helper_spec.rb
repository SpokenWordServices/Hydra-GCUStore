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

  describe "get_af_object_from_solr_doc" do
    it "should return an ActiveFedora object given a valid solr doc" do
      pid = "hydrangea:fixture_mods_article1"
      result = ActiveFedora::Base.find_by_solr(pid)
      solr_doc = result.hits.first 
      af_obj = helper.get_af_object_from_solr_doc(solr_doc)
      af_obj.parts.length.should == 1
    end
  end
  
end
