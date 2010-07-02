require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe HydrangeaArticle do
  
  before(:each) do
    @sample = HydrangeaArticle.new(:pid=>"test:HydrangeaArticleTest")
  end

  describe "create and save" do
    after(:each) do
      ActiveFedora::Base.load_instance("test:HydrangeaArticleTest").delete
    end
    it "should save and index successfully" do
      @sample.apply_depositor_metadata("Depositor ID")
      @sample.save.should == ""
    end
  end
end