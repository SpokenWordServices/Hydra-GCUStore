require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe GenericContent do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @hydra_content = GenericContent.new
  end
  
  it "Should be a kind of ActiveFedora::Base" do
    @hydra_content.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should include Hydra Model Methods" do
    @hydra_content.class.included_modules.should include(Hydra::ModelMethods)
    @hydra_content.should respond_to(:apply_depositor_metadata)
  end
  
  it "should have accessors for its default datastreams of content and original" do
   # @hydra_content.should respond_to(:has_content?)
   # @hydra_content.should respond_to(:content)
   # @hydra_content.should respond_to(:content=)
   # @hydra_content.should respond_to(:has_original?)
   # @hydra_content.should respond_to(:original)
   # @hydra_content.should respond_to(:original=)
  end

  describe ".to_solr" do
    it "should return the necessary facets" do
      @hydra_content.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
 			@hydra_content.update_indexed_attributes({[:genre_t]=>"Handbook"}, :datastreams=>"descMetadata")
      solr_doc = @hydra_content.to_solr
      solr_doc["object_type_facet"].should == "Generic content"
      solr_doc["has_model_s"].should == "info:fedora/hull-cModel:genericContent"
    end
  end

  describe "with a display_set" do
    before do
      @node = GenericContent.new
    end
    it "should have a display_set property" do
      @node.add_relationship(:is_member_of, 'hull:700')
      @node.display_set.should == 'info:fedora/hull:700'
    end
    it "should have a top_level_collection property" do
      @node.add_relationship(:is_member_of, 'hull:700')
      @node.top_level_collection.should == {:title=>["Postgraduate Medical Institute"], :pid=>"hull:700", :parent=>"info:fedora/hull:rootDisplaySet"}
    end
    it "should index the top level collection" do
       @node.add_relationship(:is_member_of, 'info:fedora/hull:rootDisplaySet')
       @node.top_level_collection.should be_nil
    end
  end
  
end

