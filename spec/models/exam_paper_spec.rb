require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe ExamPaper do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @examPaper = ExamPaper.new
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @examPaper.update_indexed_attributes({[{:organisation=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
      @examPaper.descMetadata.title_info.main_title = "FOOBAR"
      solr_doc = @examPaper.to_solr
      solr_doc["object_type_facet"].should == "Examination paper"
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:examPaper"

      ### For sorting
      solr_doc["title_facet"].should == ["FOOBAR"]
      solr_doc["year_facet"].should be_nil
      solr_doc["month_facet"].should be_nil

      #### when a date is set
      @examPaper.descMetadata.origin_info.date_issued = '2000-11-20'
      solr_doc = @examPaper.to_solr
      solr_doc["year_facet"].should == 2000
      solr_doc["month_facet"].should == 11
    end
  end

  describe "datastreams labelling" do
    it "should properly label datastreams if label option passed" do
      @examPaper.datastreams["descMetadata"].label.should == "MODS Metadata"
    end
  end

  describe "validation" do
    it "should have validation methods" do
      @examPaper.respond_to?(:valid_for_save?).should be_true
      @examPaper.respond_to?(:validate_parameters).should be_true
      @examPaper.respond_to?(:ready_for_qa?).should be_true
    end
  end

  describe "validate_parameters" do

    it "should validate the following fields: module code, module name, examination date and department" do
      @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"1999-05"}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
      @examPaper.validate_parameters(@pending_attributes).should be_true
      @examPaper.errors.should be_empty
    end

    describe "populate the errors collection when missing a value" do
#      @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"may 1999"}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
#              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
#              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
      it "should fail if missing module code" do
        @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"1999-05"}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
              [:module, :code]=>{"0"=>""}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}

        @examPaper.validate_parameters(@pending_attributes).should be_false
        @examPaper.errors.length.should == 1
      end
      it "should fail if missing module name" do
        @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"1999-05"}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>""}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
        @examPaper.validate_parameters(@pending_attributes).should be_false
        @examPaper.errors.length.should == 1
      end
      it "should fail if missing exam date" do
        @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>""}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
        @examPaper.validate_parameters(@pending_attributes).should be_false
        @examPaper.errors.length.should == 3
      end
 			it "should fail if exam date is wrong format" do
        @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"1999-05-01"}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
        @examPaper.validate_parameters(@pending_attributes).should be_false
        @examPaper.errors.length.should == 1
      end
			it "should fail if exam date is invalid" do
        @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"1999-14"}, [:organization, :namePart]=>{"0"=>"Department of Sport Science"}, 
              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
        @examPaper.validate_parameters(@pending_attributes).should be_false
        @examPaper.errors.length.should == 1
      end
      it "should fail if missing department" do
        @examPaper.pending_attributes = {"descMetadata"=>{[:origin_info, :date_issued]=>{"0"=>"1999-05"}, [:organization, :namePart]=>{"0"=>""}, 
              [:module, :code]=>{"0"=>"code"}, [:module, :name]=>{"0"=>"module"}, [:note]=>{"0"=>""}, [:language, :lang_text]=>{"0"=>"Dutch"}, 
              [:origin_info, :publisher]=>{"0"=>""}, [:exam_level]=>{"0"=>""}, [{:subject=>0}, :topic]=>{"0"=>"Subject topic goes here"}}}
        @examPaper.validate_parameters(@pending_attributes).should be_false
        @examPaper.errors.length.should == 1
      end
    end
  end
end
