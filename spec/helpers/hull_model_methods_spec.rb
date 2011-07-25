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
end
