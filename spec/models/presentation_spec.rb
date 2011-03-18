require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Presentation do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @presentation = Presentation.new
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @presentation.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
      solr_doc = @presentation.to_solr
      solr_doc["object_type_facet"].should == "Presentation"
      solr_doc["has_model_s"].should == "Presentation"
    end
  end
end
