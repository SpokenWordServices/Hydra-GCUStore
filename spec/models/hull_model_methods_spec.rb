require 'spec_helper'

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

  describe "#apply_governed_by" do
    before do
      @structural_set1 = StructuralSet.new
      @structural_set1.defaultObjectRights.update_indexed_attributes([:edit_access]=> 'baz')
      @structural_set1.save
      @structural_set2 = StructuralSet.new
      @structural_set2.defaultObjectRights.update_indexed_attributes([:edit_access]=> 'foo')
      @structural_set2.save
    end
    it "should update when it changes and copy the apo" do
      @testclassone.apply_governed_by(@structural_set1)
      ## customize rightsMetadata
      @testclassone.rightsMetadata.update_indexed_attributes([:edit_access]=> 'bar')
      @testclassone.apply_governed_by(@structural_set2)
      ## check that rightsMetadata is  overwritten by the defaultObjectRights
      @testclassone.rightsMetadata.edit_access.should == ['foo']
      
    end
    it "should not copy the apo if the structural set didn't change" do
      @testclassone.apply_governed_by(@structural_set2)
      ## customize rightsMetadata
      @testclassone.rightsMetadata.update_indexed_attributes([:edit_access]=> 'bar')
      @testclassone.apply_governed_by(@structural_set2)
      ## check that rightsMetadata is still custom
      @testclassone.rightsMetadata.edit_access.should == ['bar']
    end
    after do
      @structural_set1.delete
      @structural_set2.delete
    end
  end

  describe "#apply_set_membership" do
    before do
      @structural_set1 = StructuralSet.new
      @structural_set1.save
      @testclassone.queue_membership.should == [:proto]
    end

    it "should not add the structural set but not overwrite the protoQueue" do
      @testclassone.apply_set_membership([@structural_set1])
      @testclassone.queue_membership.should == [:proto]
    end

    after do
    end

  end


  it "should provide insert/remove methods for subject_topic" do
    @testclassone.respond_to?(:insert_subject_topic).should be_true
    @testclassone.respond_to?(:remove_subject_topic).should be_true
  end

  describe "#apply_additional_metadata" do
    before do
      @mock_desc_ds = mock("descMetadataDS")
      @mock_desc_ds.expects(:get_values).with([:title], {}).returns('My title')
      @mock_dc_ds = mock("DCDatastream")
      @mock_dc_ds.expects(:update_indexed_attributes).with([:dc_title]=>'My title')
      @testclassone.stubs(:datastreams).returns({"descMetadata"=>@mock_desc_ds, "DC"=>@mock_dc_ds})
    end
    it "should copy the date from the descMetadata to the dc datastream if it is present" do
      @mock_desc_ds.expects(:get_values).with([:origin_info, :date_issued], {}).returns('2011-10')
      @mock_dc_ds.expects(:update_indexed_attributes).with([:dc_dateIssued]=>'2011-10')
      @testclassone.apply_additional_metadata(123).should == true
    end
    it "should not copy the date from the descMetadata to the dc datastream if it isn't present" do
      @mock_desc_ds.expects(:get_values).with([:origin_info, :date_issued], {}).returns([])
      @testclassone.apply_additional_metadata(123).should == true
    end

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
      @testclassone.cmodel.should == "info:fedora/hull-cModel:testClassOne"
    end
  end
  describe "to_solr" do
    it "should apply has_model_s and fedora_owner_id correctly" do
      @testclassone.stubs(:descMetadata).returns(mock('Description Metadata', :origin_info=>nil))
      solr_doc = @testclassone.to_solr
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:testClassOne"
      solr_doc["fedora_owner_id_s"].should == "fooAdmin"
      solr_doc["fedora_owner_id_display"].should == "fooAdmin"
    end

    describe "top level collection correctly" do
      it "should have a top_level_collection and display_set if its parent is at the top level" do
      end
      it "should not have a top_level_collection but should have a display_set if its parent is not at the top level" do
      end
    end
  end
  
  describe "queue_membership" do
    it "should list all the queues of which the object asserts is_member_of" do
      @testclassone.queue_membership.should == [:proto]
    end
    it "should move the object from one queue to the next if object's state is valid" do
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
