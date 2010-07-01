require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HydrangeaFlatArticle do
  
  # Relies on the descriptor registered by config/initializers/salt_descriptors.rb
  before(:each) do
    @article = HydrangeaFlatArticle.new(:pid=>"test:never_save_this")
  end
  
  
  it "should be a kind of ActiveFedora::Base" do
    @article.should be_kind_of(ActiveFedora::Base)
    @article.should respond_to(:update_indexed_attributes)
    @article.should respond_to(:update_attributes)
  end
  
  describe "datastreams" do
    
    it "should include the desired datastreams" do
      ["rightsMetadata", "descMetadata"].each do |ds_name| 
        @article.datastreams.should have_key(ds_name)
      end
    end
    
    
    describe "descMetadata" do
      it "should include the desired fields" do
        ["title", "language", "journal_title", "abstract", "topic_tag"].each do |field_name|
           @article.datastreams["descMetadata"].fields.should have_key(field_name.to_sym)
        end
      end
    end
    
    describe "rightsMetadata" do
      it "should include the desired fields" do
        ["discover_access", "read_access", "edit_access", "discover_access_group", "read_access_group", "edit_access_group"].each do |field_name|
           @article.datastreams["rightsMetadata"].fields.should have_key(field_name.to_sym)
        end
      end
    end
    
  end
  
end
