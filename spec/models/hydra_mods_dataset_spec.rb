require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Hydra::ModsDataset do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @dataset_ds = Hydra::ModsDataset.new
  end

  describe ".new" do
    it "should initialize a new mods dataset template if no xml is provided" do
      dataset_ds = Hydra::ModsDataset.new
      dataset_ds.ng_xml.to_xml.should == Hydra::ModsDataset.xml_template.to_xml
    end
  end
 
  describe "#to_solr" do
    it "should include title" do
      # foo.datastreams["descMetadata"].class.terminology.retrieve_term(:title)
      @dataset_ds.update_indexed_attributes( {[:title_info, :main_title]=>{"0"=>"My Title"}} )
      Hydra::ModsDataset.terminology.xpath_for(:title).should == "//oxns:titleInfo/oxns:title"
      Hydra::ModsDataset.terminology.retrieve_term(:title).should be_kind_of(OM::XML::NamedTermProxy)
      @dataset_ds.to_solr["title_t"].should == ["My Title"]
    end
    it "should add an object_type_facet with 'Dataset' as the value" do
      solr_doc = @dataset_ds.to_solr
      solr_doc[:object_type_facet].should == 'Dataset'
    end
    it "should include and respond to methods from Hydra::CommonModsIndexMethods" do
      Hydra::ModsDataset.included_modules.should include Hydra::CommonModsIndexMethods
      @dataset_ds.should respond_to :extract_person_full_names
      @dataset_ds.should respond_to :extract_person_organizations
    end
  end
end
