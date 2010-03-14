require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Blacklight::CatalogHelper do
  include Blacklight::CatalogHelper
  include Blacklight::SolrHelper
  describe "setup_document_by_counter" do
    before(:each) do
      @session = {}
      @params = {}
      @reader = false
    end
    it "should have the correct qt param when the user is not of the reader role" do
      session[:search] = {:per_page=>"40",:counter=>5}
      params[:per_page] = "40"
      prev_doc = setup_document_by_counter(4)
      prev_doc[:id].should == "druid:cs409mn9638" and
      prev_doc[:id].should_not == "druid:ph537dn9961"
    end
    it "should not return a next document if we're at the last doc in a search result" do
      session[:search] = {:per_page=>"40",:counter=>5}
      params[:per_page] = "40"
      setup_next_document.should be_nil
    end
  end  
  def session
    @session
  end
  def params
    @params
  end
  def reader?
    @reader
  end
end