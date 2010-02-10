require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/shelver/indexer'

describe Shelver::Indexer do
    
  before(:each) do
     Shelver::Indexer.any_instance.stubs(:connect).returns("foo")
  
     @extractor = mock("Extractor")
     @extractor.stubs(:html_content_to_solr).returns(@solr_doc)
     @solr_doc = mock('solr_doc')
     @solr_doc.stubs(:<<)
    
      
     Shelver::Extractor.expects(:new).returns(@extractor)
     @indexer = Shelver::Indexer.new
     
   end
  
  describe "#extract_stories_to_solr" do
    before(:each) do
       @mock_story_ds = mock('stories')
       @mock_story_ds.stubs(:content).returns(fixture("druid-cm234kq4672-stories.xml"))
     
       @mock_document =  mock("Document")
       @mock_document.stubs(:pid)
       @mock_document.stubs(:label)
       @mock_document.stubs(:datastream)
     end #:each
    
   describe "stories to solr" do
      it "should add content from stories dstream into solr doc when its not new" do
      
       @extractor.expects(:html_content_to_solr).once
       @mock_story_ds.stubs(:new_object?).returns(false)
       
       Shelver::Repository.expects(:get_datastream).with(@mock_document, "stories").returns(@mock_story_ds)
       @indexer.extract_stories_to_solr(@mock_document, "stories", @solr_doc)
        
      end
    end
    
    describe "no stories not to solr" do
      it "should not add content from stories dstream if the object is new" do
       
         @extractor.expects(:html_content_to_solr).never
         @mock_story_ds.stubs(:new_object?).returns(true)
        
         Shelver::Repository.expects(:get_datastream).with(@mock_document, 'stories').returns(@mock_story_ds)
         @indexer.extract_stories_to_solr(@mock_document , "stories", @solr_doc)
     
        end
      end
  end
  
  
  describe "#solrize" do
    it "should convert a hash to a solr doc" do
      example_hash = {"box"=>"Box 51A", "city"=>["Ann Arbor", "Hyderabad", "Palo Alto"], "person"=>["ELLIE ENGELMORE", "Reddy", "EDWARD FEIGENBAUM"], "title"=>"Letter from Ellie Engelmore to Professor K. C. Reddy", "series"=>"eaf7000", "folder"=>"Folder 15", "technology"=>["artificial intelligence"], "year"=>"1985", "organization"=>["Heuristic Programming Project", "Mathematics and Computer/Information Sciences University of Hyderabad Central University P. O. Hyder", "Professor K. C. Reddy School of Mathematics and Computer/Information Sciences"], "collection"=>"e-a-feigenbaum-collection", "state"=>["Michigan", "California"]}
      
      example_result = Shelver::Indexer.solrize( example_hash )
      example_result.should be_kind_of Solr::Document
      example_hash.each_pair do |key,values|
        if values.class == String
          example_result["#{key}_facet"].should == values
        else
          values.each do |v|
            example_result.inspect.include?"@name=\"#{key}_facet\", @boost=nil, @value=\"#{v}\"".should be_true 
          end
        end        
      end
    end
    
    it "should handle hashes with facets listed in a sub-hash" do
      simple_hash = Hash[:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}]
      result = Shelver::Indexer.solrize( simple_hash )
      result.should be_kind_of Solr::Document
      result["technology_facet"].should == "t1"
      result.inspect.include?'@name="technology_facet", @boost=nil, @value="t2"'.should be_true
      result["company_facet"].should == "c1"
      result["person_facet"].should == "p1"
      result.inspect.include?'@name="person_facet", @boost=nil, @value="p2"'.should be_true
    end
    
    it "should create symbols from the :symbols subhash" do
      simple_hash = Hash[:facets => {'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}, :symbols=>{'technology'=>["t1", "t2"], 'company'=>"c1", "person"=>["p1", "p2"]}]
      result = Shelver::Indexer.solrize( simple_hash )
      result.should be_kind_of Solr::Document
      result["technology_s"].should == "t1"
      result.inspect.include?'@name="technology_s", @boost=nil, @value="t2"'.should be_true
      result["company_s"].should == "c1"
      result["person_s"].should == "p1"
      result.inspect.include?'@name="person_s", @boost=nil, @value="p2"'.should be_true
    end
  end
end
