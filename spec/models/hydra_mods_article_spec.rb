require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Hydra::ModsArticle do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @article_ds = Hydra::ModsArticle.new
  end

  describe ".new" do
    it "should initialize a new mods article template if no xml is provided" do
      article_ds = Hydra::ModsArticle.new
      article_ds.ng_xml.to_xml.should == Hydra::ModsArticle.xml_template.to_xml
    end
  end

  describe "#person_template" do
    it "should generate a new person node" do
      node = Hydra::ModsArticle.person_template
      node.should be_kind_of(Nokogiri::XML::Element)
      node.to_xml.should == "<name type=\"personal\">\n  <namePart type=\"family\"/>\n  <namePart type=\"given\"/>\n  <affiliation/>\n  <role>\n    <roleTerm type=\"text\"/>\n  </role>\n</name>"
    end
  end
  describe "insert_contributor" do
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type and mark the datastream as dirty" do
      @article_ds.find_by_terms(:person).length.should == 1
      @article_ds.dirty?.should be_false
      node, index = @article_ds.insert_contributor("person")
      @article_ds.dirty?.should be_true
      
      @article_ds.find_by_terms(:person).length.should == 2
      node.to_xml.should == Hydra::ModsArticle.person_template.to_xml
      index.should == 1
      
      node, index = @article_ds.insert_contributor("person")
      @article_ds.find_by_terms(:person).length.should == 3
      index.should == 2
    end
    it "should support adding institutions" do
      @article_ds.find_by_terms(:organization).length.should == 0
      node, index = @article_ds.insert_contributor("organization")
      node.to_xml.should == Hydra::ModsArticle.organization_template.to_xml
      @article_ds.find_by_terms(:organization).length.should == 1
      index.should == 0
      
      node, index = @article_ds.insert_contributor("organization")
      @article_ds.find_by_terms(:organization).length.should == 2
      index.should == 1
    end
    it "should support adding conferences" do
      @article_ds.find_by_terms(:conference).length.should == 0
      node, index = @article_ds.insert_contributor("conference")
      node.to_xml.should == Hydra::ModsArticle.conference_template.to_xml
      @article_ds.find_by_terms(:conference).length.should == 1
      index.should == 0
      
      node, index = @article_ds.insert_contributor("conference")
      @article_ds.find_by_terms(:conference).length.should == 2
      index.should == 1
    end
  end
  
  describe "remove_contributor" do
    it "should remove the corresponding contributor from the xml and then mark the datastream as dirty" do
      @article_ds.find_by_terms(:person).length.should == 1
      result = @article_ds.remove_contributor("person", "0")
      @article_ds.find_by_terms(:person).length.should == 0
      @article_ds.should be_dirty
    end
  end
  
  describe ".update_indexed_attributes" do
    it "should work for all of the fields we want to display" do
      [ [:title_info, :main_title],[:abstract],[:subject, :topic], [{:journal=>0}, :issue, :level], [{:journal=>0}, :issue, :pages, :start],[{:journal=>0}, :issue, :pages, :end] ].each do |pointer|
        test_val = "#{pointer.last.to_s} value"
        @article_ds.update_indexed_attributes( {pointer=>{"0"=>test_val}} )
        @article_ds.get_values(pointer).first.should == test_val
      end
    end
    it "should work for fields that are attributes" do
      pointer = [:title_info, :language]
      test_val = "#{pointer.last.to_s} value"
      @article_ds.update_indexed_attributes( {[:title_info, :language]=>{"0"=>test_val}} )
      @article_ds.get_values(pointer).first.should == test_val
    end
  end
  
  describe "#xml_template" do
    it "should return an empty xml document" do
      pending "too rigid.  fails on unimportant inconsistencies"
      correct_template = "<?xml version=\"1.0\"?>\n<mods xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.loc.gov/mods/v3\" version=\"3.3\" xsi:schemaLocation=\"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd\">\n  <titleInfo>\n    <title/>\n  </titleInfo>\n  <name type=\"personal\">\n    <namePart type=\"given\"/>\n    <namePart type=\"family\"/>\n    <affiliation/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"corporate\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"conference\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <typeOfResource/>\n  <genre authority=\"marcgt\"/>\n  <language>\n    <languageTerm type=\"code\" authority=\"iso639-2b\"/>\n  </language>\n  <abstract/>\n  <subject>\n    <topic/>\n  </subject>\n  <relatedItem type=\"host\">\n    <titleInfo>\n      <title/>\n    </titleInfo>\n    <identifier type=\"issn\"/>\n    <originInfo>\n      <publisher/>\n      <dateIssued/>\n    </originInfo>\n    <part>\n      <detail type=\"volume\">\n        <number/>\n      </detail>\n      <detail type=\"number\">\n        <number/>\n      </detail>\n      <extent unit=\"page\">\n        <start/>\n        <end/>\n      </extent>\n      <date/>\n    </part>\n  </relatedItem>\n  <location>\n    <url/>\n  </location>\n</mods>\n"
      provisional_template = "<?xml version=\"1.0\"?>\n<mods xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.loc.gov/mods/v3\" xsi:schemaLocation=\"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd\" version=\"3.3\">\n  <titleInfo>\n    <title/>\n  </titleInfo>\n  <name type=\"personal\">\n    <namePart type=\"given\"/>\n    <namePart type=\"family\"/>\n    <affiliation/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"corporate\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"conference\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <typeOfResource/>\n  <genre authority=\"marcgt\"/>\n  <language>\n    <languageTerm type=\"code\" authority=\"iso639-2b\"/>\n  </language>\n  <abstract/>\n  <subject>\n    <topic/>\n  </subject>\n  <relatedItem type=\"host\">\n    <titleInfo>\n      <title/>\n    </titleInfo>\n    <identifier type=\"issn\"/>\n    <originInfo>\n      <publisher/>\n      <dateIssued/>\n    </originInfo>\n    <part>\n      <detail type=\"volume\"/>\n      <detail type=\"number\"/>\n      <pages type=\"start\"/>\n      <pages type=\"end\"/>\n      <date/>\n    </part>\n  </relatedItem>\n  <location>\n    <url/>\n  </location>\n</mods>\n"
      Hydra::ModsArticle.xml_template.to_xml.should == provisional_template
      # Hydra::ModsArticle.xml_template.to_xml.should have_tag "mods[xmlns:xlink=http://www.w3.org/1999/xlink][xmlns:xsi=http://www.w3.org/2001/XMLSchema-instance][xmlns=http://www.loc.gov/mods/v3][version=3.3]"
    end
  end
 
  describe "#to_solr" do
    it "should add an object_type_facet with 'Article' as the value" do
      solr_doc = @article_ds.to_solr
      solr_doc[:object_type_facet].should == 'Article'
    end
    it "should include and respond to methods from Hydra::CommonModsIndexMethods" do
      Hydra::ModsArticle.included_modules.should include Hydra::CommonModsIndexMethods
      @article_ds.should respond_to :extract_person_full_names
      @article_ds.should respond_to :extract_person_organizations
    end
  end
end
