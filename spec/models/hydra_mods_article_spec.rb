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
  describe "#xml_template" do
    it "should return an empty xml document" do
      correct_template = "<?xml version=\"1.0\"?>\n<mods xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.loc.gov/mods/v3\" version=\"3.3\" xsi:schemaLocation=\"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd\">\n  <titleInfo>\n    <title/>\n  </titleInfo>\n  <name type=\"personal\">\n    <namePart type=\"given\"/>\n    <namePart type=\"family\"/>\n    <affiliation/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"corporate\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"conference\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <typeOfResource/>\n  <genre authority=\"marcgt\"/>\n  <language>\n    <languageTerm type=\"code\" authority=\"iso639-2b\"/>\n  </language>\n  <abstract/>\n  <subject>\n    <topic/>\n  </subject>\n  <relatedItem type=\"host\">\n    <titleInfo>\n      <title/>\n    </titleInfo>\n    <identifier type=\"issn\"/>\n    <originInfo>\n      <publisher/>\n      <dateIssued/>\n    </originInfo>\n    <part>\n      <detail type=\"volume\">\n        <number/>\n      </detail>\n      <detail type=\"number\">\n        <number/>\n      </detail>\n      <extent unit=\"page\">\n        <start/>\n        <end/>\n      </extent>\n      <date/>\n    </part>\n  </relatedItem>\n  <location>\n    <url/>\n  </location>\n</mods>\n"
      provisional_template = "<?xml version=\"1.0\"?>\n<mods xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.loc.gov/mods/v3\" version=\"3.3\" xsi:schemaLocation=\"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd\">\n  <titleInfo>\n    <title/>\n  </titleInfo>\n  <name type=\"personal\">\n    <namePart type=\"given\"/>\n    <namePart type=\"family\"/>\n    <affiliation/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"corporate\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <name type=\"conference\">\n    <namePart/>\n    <role>\n      <roleTerm type=\"text\" authority=\"marcrelator\"/>\n    </role>\n  </name>\n  <typeOfResource/>\n  <genre authority=\"marcgt\"/>\n  <language>\n    <languageTerm type=\"code\" authority=\"iso639-2b\"/>\n  </language>\n  <abstract/>\n  <subject>\n    <topic/>\n  </subject>\n  <relatedItem type=\"host\">\n    <titleInfo>\n      <title/>\n    </titleInfo>\n    <identifier type=\"issn\"/>\n    <originInfo>\n      <publisher/>\n      <dateIssued/>\n    </originInfo>\n    <part>\n      <detail type=\"volume\"/>\n      <detail type=\"number\"/>\n      <pages type=\"start\"/>\n      <pages type=\"end\"/>\n      <date/>\n    </part>\n  </relatedItem>\n  <location>\n    <url/>\n  </location>\n</mods>\n"
      Hydra::ModsArticle.xml_template.to_xml.should == provisional_template
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
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type" do
      @article_ds.retrieve(:person).length.should == 1
      node, index = @article_ds.insert_contributor("person")
      @article_ds.retrieve(:person).length.should == 2
      node.to_xml.should == Hydra::ModsArticle.person_template.to_xml
      index.should == 1
      
      node, index = @article_ds.insert_contributor("person")
      @article_ds.retrieve(:person).length.should == 3
      index.should == 2
    end
    it "should support adding institutions" do
      @article_ds.retrieve(:organization).length.should == 1
      node, index = @article_ds.insert_contributor("organization")
      node.to_xml.should == Hydra::ModsArticle.organization_template.to_xml
      @article_ds.retrieve(:organization).length.should == 2
      index.should == 1
    end
    it "should support adding conferences" do
      @article_ds.retrieve(:conference).length.should == 1
      node, index = @article_ds.insert_contributor("conference")
      node.to_xml.should == Hydra::ModsArticle.conference_template.to_xml
      @article_ds.retrieve(:conference).length.should == 2
      index.should == 1
    end
  end
  describe ".update_indexed_attributes" do
    it "should work for all of the fields we want to display" do
      [ [:title_info, :main_title],[:abstract],[:subject, :topic],[:title_info, :language], [:organization, :role], [{:journal=>0}, :issue, :level], [{:journal=>0}, :issue, :start_page],[{:journal=>0}, :issue, :end_page] ].each do |pointer|
        test_val = "#{pointer.last.to_s} value"
        @article_ds.update_indexed_attributes( {pointer=>{"0"=>test_val}} )
        @article_ds.get_values(pointer).first.should == test_val
      end
    end
  end
end