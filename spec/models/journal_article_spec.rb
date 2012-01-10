require 'spec_helper'
require "active_fedora"
require "nokogiri"

describe JournalArticle do
  
  before(:each) do
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

  describe "apply_additional_metadata" do
    before do
      @desc_ds = @journalArticle.descMetadata
      @desc_ds.update_indexed_attributes({[:title] => ["My title"]})
    end
    it "should copy the date from the descMetadata to the dc datastream if it is present" do
      @desc_ds.update_indexed_attributes({[:origin_info, :date_issued] => ['2011-10']})
      @journalArticle.apply_additional_metadata(123).should == true
      @journalArticle.dc.dc_date.should == ['2011-10']
      @journalArticle.dc.dc_title.should == ["My title"]
    end
    it "should not copy the date from the descMetadata to the dc datastream if it isn't present" do
      @journalArticle.apply_additional_metadata(123).should == true
      @journalArticle.dc.dc_date.should == [""]
      @journalArticle.dc.dc_title.should == ["My title"]
    end
  end
end
