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
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:presentation"
    end
  end
  describe "apply_additional_metadata" do
    before do
      @desc_ds = @presentation.datastreams_in_memory["descMetadata"]
      @desc_ds.update_indexed_attributes({[:title] => ["My title"]})
    end
    it "should copy the date from the descMetadata to the dc datastream if it is present" do
      @desc_ds.update_indexed_attributes({[:origin_info, :date_issued] => ['2011-10']})
      @presentation.apply_additional_metadata(123).should == true
      @presentation.datastreams_in_memory["DC"].dc_title.should == ["My title"]
      pending  #It's using ModsPresentation which doesn't have [:origin_info,:date_issued]
      @presentation.datastreams_in_memory["DC"].dc_dateIssued.should == ['2011-10']
    end
    it "should not copy the date from the descMetadata to the dc datastream if it isn't present" do
      @presentation.apply_additional_metadata(123).should == true
      @presentation.datastreams_in_memory["DC"].dc_dateIssued.should == [""]
      @presentation.datastreams_in_memory["DC"].dc_title.should == ["My title"]
    end
  end
end
