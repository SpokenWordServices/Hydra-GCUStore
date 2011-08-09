require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

class TestClassOne < ActiveFedora::Base
  include HullModelMethods

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
    self.add_relationship :is_member_of, "info:fedora/hull:protoQueue"
  end

end

class TestClassTwo < UketdObject
  def owner_id
    "fooAdmin"
  end

  def initialize
    super
    self.add_relationship :is_member_of, "info:fedora/hull:protoQueue"
  end
end

describe HullModelMethods do
  before(:each) do
    @testclassone = TestClassOne.new
  end

  it "should provide insert/remove methods for subject_topic" do
    @testclassone.respond_to?(:insert_subject_topic).should be_true
    @testclassone.respond_to?(:remove_subject_topic).should be_true
  end

  describe "#insert_subject_topic" do
    it "should wrap the insert_subject_topic of the underlying datastream" do
      mock_desc_ds = mock("Datastream")
      mock_node = mock("subject_node")
      mock_node.expects(:inner_text=).with("foobar")
      mock_desc_ds.expects(:insert_subject_topic).returns(mock_node,0)
      @testclassone.stubs(:datastreams_in_memory).returns({"descMetadata"=>mock_desc_ds})
      node, index = @testclassone.insert_subject_topic(:value => "foobar") 
    end
  end

  it "should provide a helper method for inserting resource records into contentMetatdat" do
    @testclassone.respond_to?(:insert_resource)
  end

  describe "cmodel" do
    it "should properly return the appropriate c-Model declaration" do
      helper.stubs(:class).returns(JournalArticle)
      helper.cmodel.should == "info:fedora/hull-cModel:journalArticle"
      
      @testclassone.cmodel.should == "info:fedora/hull-cModel:testClassOne"
    end
  end
  describe "to_solr" do
    it "should apply has_model_s and fedora_owner_id correctly" do
      solr_doc = @testclassone.to_solr
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:testClassOne"
      solr_doc["fedora_owner_id_s"].should == "fooAdmin"
      solr_doc["fedora_owner_id_display"].should == "fooAdmin"
    end
  end
  
  describe "queue_membership" do
    it "should list all the queues of which the object asserts is_member_of" do
      @testclassone.queue_membership.should == [:proto]
    end
    it "should move the object from one queue to the next if ojbect's state is valid" do
      testclasstwo = TestClassTwo.new
      testclasstwo.expects(:ready_for_qa?).returns(true)
      testclasstwo.expects(:owner_id=).with("fedoraAdmin")
      testclasstwo.queue_membership.should == [:proto]
      testclasstwo.change_queue_membership(:qa)
      testclasstwo.queue_membership.should == [:qa]
			testclasstwo.is_governed_by_queue_membership.should == [:qa]
    end    
  end

  it "should provide .pid_namespace method for appropriate c-model declaration" do
    TestClassOne.should respond_to(:pid_namespace)
    TestClassOne.pid_namespace.should == "hull-cModel"
  end
  
  context "full text" do

    it "should return an empty string if an error is returned from the extractor" do
      file = File.open("spec/fixtures/bad_content.pdf","r")
      etd = UketdObject.new
      etd.extract_content(file).should be_empty
    end

    it "should return a string containing the contents of the pdf" do
      file = File.open("spec/fixtures/good_content.pdf","r")
      etd = UketdObject.new
      etd.extract_content(file).should_not be_empty
    end

    context "atomistic" do
      it "should index child objects' binary files as full text in the content field" do
        etd = UketdObject.load_instance "hull:3108"
        solr_doc = etd.to_solr
        solr_doc.keys.include?("text").should be_true
        solr_doc.fetch("text","").include?("mnesarchum efficiantur").should be_true
      end
      it ".get_extracted_content should get all child assests" do
        etd = UketdObject.load_instance "hull:3108"
        contents = etd.get_extracted_content
        contents.should be_kind_of(String)
        contents.include?('mnesarchum efficiantur').should be_true
      end
      it "should solrizer appropriately" do
        s = Solrizer::Fedora::Solrizer.new
        s.solrize "hull:3108"
        response = ActiveFedora::Base.find_by_fields_by_solr({:text=>"mnesarchum"}, {:field_list => ["id"]})
        ids = response.hits.map{|hit| hit.values.first }
        ids.include?("hull:3108").should be_true
        ids.length.should > 0
      end
    end
    context "compound" do
      it "should index objects file datastreams as full text in the content field" do
        ep = ExamPaper.load_instance "hull:1765"
        solr_doc = ep.to_solr
        solr_doc.keys.include?("text").should be_true
        solr_doc.fetch("text","").include?("mnesarchum efficiantur").should be_true
      end
      it "should solizer appropriately" do
        s = Solrizer::Fedora::Solrizer.new
        s.solrize "hull:1765"
        response = ActiveFedora::Base.find_by_fields_by_solr({:text=>"mnesarchum"}, {:field_list => ["id"]})
        ids = response.hits.map{|hit| hit.values.first }
        ids.include?("hull:1765").should be_true
        ids.length.should > 0
      end
    end
  end

end
