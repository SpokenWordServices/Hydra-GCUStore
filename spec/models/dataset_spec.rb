require 'spec_helper'
require "active_fedora"

describe Dataset do
  
  before(:each) do
    @dataset = Dataset.new
  end
  
  it "Should be a kind of ActiveFedora::Base" do
    @dataset.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should include Hydra Model Methods" do
    @dataset.class.included_modules.should include(Hydra::ModelMethods)
    @dataset.should respond_to(:apply_depositor_metadata)
  end
  
  describe ".to_solr" do
    it "should return the necessary facets" do
      @dataset.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
 			  @dataset.update_indexed_attributes({[:genre_t]=>"Dataset"}, :datastreams=>"descMetadata")
      solr_doc = @dataset.to_solr
      solr_doc["object_type_facet"].should == "Dataset"
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:dataset"
    end
  end

  describe "set membership" do
    before do
      @node = Dataset.new
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
  

  describe "validations" do
    it "should fail if dataset date is invalid" do
       @dataset.pending_attributes = {"descMetadata"=>{[:date_issued]=>{"0"=>"1999-15"}, [:location_subject, :cartographics, :coordinates]=>{"0"=>""} }}
      @dataset.validate_parameters().should be_false
      @dataset.errors.length.should == 1
      @dataset.errors.first.should == "descMetadata error: invalid date"
    end
    it "should pass if dataset date is valid" do
      @dataset.pending_attributes = {"descMetadata"=>{[:date_issued]=>{"0"=>"1999-12/2001-05-06"}, [:location_subject, :cartographics, :coordinates]=>{"0"=>""} }}
      @dataset.validate_parameters().should be_true
      @dataset.errors.length.should == 0
    end
    it "should pass if dataset is blank" do
       @dataset.pending_attributes = {"descMetadata"=>{[:date_issued]=>{"0"=>""}, [:location_subject, :cartographics, :coordinates]=>{"0"=>""} }}
      @dataset.validate_parameters().should be_true
      @dataset.errors.length.should == 0
    end
  end

  describe "genre" do
    it "should set the cModel and genre" do
      @dataset.descMetadata.genre.should == ["Dataset"]
      #@dataset.relationships(:has_model).should == ["info:fedora/hull-cModel:dataset"]
    end
    
  end  
end

