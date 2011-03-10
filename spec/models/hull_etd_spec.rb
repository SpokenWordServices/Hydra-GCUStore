require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe HullEtd do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @etd = HullEtd.new
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @etd.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
      solr_doc = @etd.to_solr
      solr_doc["person_institution_t"].should == ["my org" ]       
      solr_doc["person_institution_facet"].should == ["my org"]        
      solr_doc["object_type_facet"].should == "ETD"
    end
  end
end
