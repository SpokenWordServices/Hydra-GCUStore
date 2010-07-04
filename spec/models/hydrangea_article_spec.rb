require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe HydrangeaArticle do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @article = HydrangeaArticle.new
  end
  
  describe "insert_contributor" do
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type, and then mark the datastream as dirty" do
      mods_ds = @article.datastreams_in_memory["descMetadata"]
      mods_ds.expects(:insert_contributor).with("person",{})
      node, index = @article.insert_contributor("person")
    end
  end
  
  describe "apply_depositor_metadata" do
    it "should set depositor info in the properties and rightsMetadata datastreams" do
      rights_ds = @article.datastreams_in_memory["rightsMetadata"]
      prop_ds = @article.datastreams_in_memory["properties"]

      node, index = @article.apply_depositor_metadata("Depositor Name")
      
      prop_ds.depositor_values.should == ["Depositor Name"]
      rights_ds.get_values([:edit_access, :person]).should == ["Depositor Name"]
    end
  end
end