require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Document do
  
  # Relies on the descriptor registered by config/initializers/salt_descriptors.rb
  before(:each) do
    @document = Document.new
  end
  
  
  it "should be a kind of ActiveFedora::Base" do
    @document.should be_kind_of(ActiveFedora::Base)
    @document.should respond_to(:update_indexed_attributes)
    @document.should respond_to(:update_attributes)
  end
  
  describe "datastreams" do
    
    it "should include the desired datastreams" do
      ["descMetadata", "properties"].each do |ds_name| 
        @document.datastreams.should have_key(ds_name)
        #@document.datastreams[ds_name].class.should be_kind_of(ActiveFedora::Datastream)
      end
    end
    
    # author, date, title, medium, format, access, rights
    # location?
    # stories
    # tags
    # urls (retrieved by get_suppl_urls)
    
    
    describe "descMetadata" do
      it "should include the desired fields" do
        ["type", "medium", "rights", "date", "format", "title", "publisher"].each do |field_name|
           @document.datastreams["descMetadata"].fields.should have_key(field_name.to_sym)
        end
      end
    end
    
    describe "properties" do
      it "should include the desired fields" do
        pending
        ["creation_date", "abstract", "rights", "subject_heading", "spati"]
      end
    end
  end

  
  
end