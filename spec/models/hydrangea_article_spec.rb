require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe HydrangeaArticle do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @article = HydrangeaArticle.new
  end
  
  describe "insert_contributor" do
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type" do
      mods_ds = @article.datastreams_in_memory["descMetadata"]
      mods_ds.expects(:insert_contributor).with("person",{})
      node, index = @article.insert_contributor("person")
    end
  end
end