require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active-fedora"
require "nokogiri"

describe UketdObject do
  context "full text" do

    it "should index child objects' binary files as full text in the content field" do
      etd = UketdObject.load_instance "hull:3108"
      solr_doc = etd.to_solr
      solr_doc.keys.include?("content").should be_true
      solr_doc.fetch("content","").include?("mnesarchum efficiantur").should be_true
    end
    it ".get_extracted_content should get all child assests" do
      etd = UketdObject.load_instance "hull:3108"
      contents = etd.get_extracted_content
      contents.should be_kind_of(String)
      contents.include?('mnesarchum efficiantur').should be_true
    end
    it "should solrizer appropriately" do
      s = Solrizer::Fedora::Solrizer.new
      s.solrize "hull:3108"
      response = ActiveFedora::Base.find_by_fields_by_solr(:content=>"mnesarchum")
      response.hits.count.should == 1
    end
  end
  
  context "original spec" do
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

    describe ".initialize" do
      it "should create the appropriate cModel declarations" do
        @etd.relationships[:self][:has_model].should == ["info:fedora/hydra-cModel:genericParent", "info:fedora/hydra-cModel:commonMetadata"]
      end
    end
  end
end
