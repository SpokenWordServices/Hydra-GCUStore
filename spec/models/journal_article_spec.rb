require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe JournalArticle do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @journalArticle = JournalArticle.new
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @journalArticle.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
      solr_doc = @journalArticle.to_solr
      solr_doc["object_type_facet"].should == "Journal article"
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:journalArticle"
    end
  end
end
