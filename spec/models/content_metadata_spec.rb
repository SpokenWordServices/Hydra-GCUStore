require 'spec_helper'
describe ContentMetadata do
  
  before(:each) do
    repository = stub('repo', :datastream_dissemination=>'', :datastream=>'', :add_datastream=>'')
    @inner_obj = stub('inner obj', :repository => repository, :pid=>'__PID__' )
    @content_metadata_ds = ContentMetadata.new(@inner_obj, nil)
  end

  describe ".new" do
    it "should initialize a new content metadata template if no xml is provided" do
      content_metadata_ds = ContentMetadata.new(@inner_obj, nil)
      content_metadata_ds.ng_xml.to_xml.should == ContentMetadata.xml_template.to_xml
    end
  end

  describe "#resource_template" do
    it "should generate a new resource node" do
      node = ContentMetadata.resource_template
      node.should be_kind_of(Nokogiri::XML::Element)
      node.to_xml.should be_equivalent_to("<resource dissType=\"genericContent/content\" displayLabel=\"\" objectID=\"\" sequence=\"\" dsID=\"content\" id=\"Asset \">\n  <file format=\"pdf\" size=\"\" id=\"Asset \" mimeType=\"application/pdf\">\n    <location type=\"url\"></location>\n  </file>\n</resource>")
    end
  end
  describe "insert_resource" do
    it "should generate a new contributor of type (type) into the current xml, treating strings and symbols equally to indicate type and mark the datastream as dirty" do
      @content_metadata_ds.find_by_terms(:resource).length.should == 0
      @content_metadata_ds.dirty?.should be_false
      node, index = @content_metadata_ds.insert_resource()
      @content_metadata_ds.dirty?.should be_true
      
      @content_metadata_ds.find_by_terms(:resource).length.should == 1
      node.to_xml.should == ContentMetadata.resource_template(:sequence=>"1").to_xml
      index.should == 0
      
      node, index = @content_metadata_ds.insert_resource()
      @content_metadata_ds.find_by_terms(:resource).length.should == 2
      index.should == 1
    end
  end
  
  describe "remove_resource" do
    it "should remove the corresponding resource from the xml and then mark the datastream as dirty" do
      @content_metadata_ds.insert_resource
      @content_metadata_ds.save
      @content_metadata_ds.find_by_terms(:resource).length.should == 1
      result = @content_metadata_ds.remove_resource("0")
      @content_metadata_ds.find_by_terms(:resource).length.should == 0
      @content_metadata_ds.should be_dirty
    end
  end
  
 
end

