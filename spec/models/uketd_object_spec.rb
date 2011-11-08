require 'spec_helper'
require "active-fedora"
require "nokogiri"

describe UketdObject do
  
  context "original spec" do
    before(:each) do
      #Fedora::Repository.stubs(:instance).returns(stub_everything())
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

    describe ".initialize" do
      it "should create the appropriate cModel declarations" do
        @etd.ids_for_outbound(:has_model).should == ["hydra-cModel:genericParent", "hydra-cModel:commonMetadata"]
      end
    end
  end
end
