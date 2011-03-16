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
      solr_doc["person_institution_t"].should == ["my org" ]       
      solr_doc["person_institution_facet"].should == ["my org"]        
      solr_doc["object_type_facet"].should == "ETD"
      solr_doc["has_model_s"].should == "UketdObject"
    end
  end
end
