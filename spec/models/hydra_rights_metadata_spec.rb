require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Hydra::RightsMetadata do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @sample = Hydra::RightsMetadata.new
  end
  
  describe "update_indexed_attributes" do
    it "should update the declared properties" do
      @sample.retrieve(*[:edit_access, :person]).length.should == 0
      @sample.update_properties([:edit_access, :person]=>"user id").should == {"edit_access_person"=>{"0"=>"user id"}}
      @sample.retrieve(*[:edit_access, :person]).length.should == 1
      @sample.retrieve(*[:edit_access, :person]).first.text.should == "user id"
    end
  end
  describe "to_solr" do
    it "should populate solr doc with the correct fields" do
      params = {[:edit_access, :person]=>"Lil Kim", [:edit_access, :group]=>["group1","group2"], [:discover_access, :group]=>["public"],[:discover_access, :person]=>["Joe Schmoe"]}
      @sample.update_properties(params)
      solr_doc = @sample.to_solr
      
      solr_doc[:edit_access_person_t].should == "Lil Kim"
      solr_doc[:edit_access_group_t].should == "group1"
      solr_doc[:edit_access_group_t].should include("group1")
      solr_doc[:discover_access_person_t].should == "Joe Schmoe"
      solr_doc[:discover_access_group_t].should == "public"
    end
    it "should solrize fixture content correctly" do
      fixture_xml = Nokogiri::XML::Document.parse( fixture("hydrangea_fixture_mods_article1.foxml.xml") )
      fixture_rights = fixture_xml.xpath("//foxml:datastream[@ID='rightsMetadata']/foxml:datastreamVersion[last()]/foxml:xmlContent").first.to_xml
      lsample = Hydra::RightsMetadata.from_xml(fixture_rights)
      solr_doc = lsample.to_solr
      solr_doc[:edit_access_person_t].should == "researcher1"
      solr_doc[:edit_access_group_t].should == "archivist"
      solr_doc[:read_access_group_t].should == "public"
      solr_doc[:discover_access_group_t].should == "public"
    end
  end
end