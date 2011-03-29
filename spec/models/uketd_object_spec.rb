require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe UketdObject do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @etd = UketdObject.new
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @etd.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
      solr_doc = @etd.to_solr
      solr_doc["object_type_facet"].should == "Thesis or dissertation"
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:uketdObject"
    end
  end
end
