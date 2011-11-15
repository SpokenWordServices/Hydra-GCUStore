require 'spec_helper'
require "active_fedora"

describe GenericContent do
  
  before(:each) do
#    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @generic_content = GenericContent.new
  end
  
  it "Should be a kind of ActiveFedora::Base" do
    @generic_content.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should include Hydra Model Methods" do
    @generic_content.class.included_modules.should include(Hydra::ModelMethods)
    @generic_content.should respond_to(:apply_depositor_metadata)
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @generic_content.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
 			@generic_content.update_indexed_attributes({[:genre_t]=>"Handbook"}, :datastreams=>"descMetadata")
      solr_doc = @generic_content.to_solr
      solr_doc["object_type_facet"].should == "Generic content"
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:genericContent"
    end
  end

  describe "set membership" do
    before do
      @node = GenericContent.new
    end
    it "should have a structural_set property" do
      @node.apply_set_membership(['info:fedora/hull:669'])
      @node.structural_set.should == 'info:fedora/hull:669'
    end
    it "should have a display_set property" do
      @node.add_relationship(:is_member_of, 'info:fedora/hull:700')
      @node.display_set.should == 'info:fedora/hull:700'
    end
    it "should index the top level collection" do
       @node.add_relationship(:is_member_of, 'info:fedora/hull:rootDisplaySet')
       @node.to_solr['top_level_collection_id_s'].should == 'info:fedora/hull:rootDisplaySet'
    end
  end
  
  describe "attributes=" do
    before do
      @node = GenericContent.new
      @sample_post_params = {
        "generic_content" => {
          "subjects" =>[
            {
                "topic" => "Subject 1",
                "category" => "topic"
              },{
                "topic" => "Subject 2",
                "category" => "geographic"      
            }
            ]
      }}
      
    end
    it "with subjects" do
      @node.attributes = @sample_post_params["generic_content"]
      @node.descMetadata.subject.length.should == 2
      @node.descMetadata.subject(0).topic.should == ["Subject 1"]
      @node.descMetadata.subject(0).category.should == ["topic"]
      @node.descMetadata.subject(1).topic.should == ["Subject 2"]
      @node.descMetadata.subject(1).category.should == ["geographic"]
    end
  end

  describe "validations" do
    it "should fail if exam date is invalid" do
      @generic_content.pending_attributes = {"descMetadata"=>{[:date_valid]=>{"0"=>"1999-14"} }}
      @generic_content.validate_parameters().should be_false
      @generic_content.errors.length.should == 1
      @generic_content.errors.first.should == "descMetadata error: invalid date"
    end
    it "should pass if exam date is valid" do
      @generic_content.pending_attributes = {"descMetadata"=>{[:date_valid]=>{"0"=>"1999-12/2001-05-06"} }}
      @generic_content.validate_parameters().should be_true
      @generic_content.errors.length.should == 0
    end
    it "should pass if exam date is blank" do
      @generic_content.pending_attributes = {"descMetadata"=>{[:date_valid]=>{"0"=>""} }}
      @generic_content.validate_parameters().should be_true
      @generic_content.errors.length.should == 0
    end
  end

  
end

