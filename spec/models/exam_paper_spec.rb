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
      @examPaper.update_indexed_attributes({[{:corporate_name=>0}, :department_name]=>"my org"}, :datastreams=>"descMetadata")
      solr_doc = @examPaper.to_solr
      solr_doc["corporate_name_department_name_t"].should == ["my org" ]       
      solr_doc["corporate_name_department_name_facet"].should == ["my org"]        
      solr_doc["object_type_facet"].should == "Examination paper"
    end
  end
end
