require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'solrizer'
require "solrizer/fedora"


describe Solrizer::Fedora::Indexer do
  
  before(:all) do
    
    
  end
  
  before(:each) do
    
       @extractor = mock("Extractor")
       @extractor.stubs(:html_content_to_solr).returns(@solr_doc)
       @solr_doc = Hash.new
       Solrizer::Extractor.expects(:new).returns(@extractor)
  end
    
  describe "#new" do
    it "should return a URL from solr_config if the config has a :url" do
          Blacklight.stubs(:solr_config).returns({:url => "http://foo.com:8080/solr"})
          @indexer = Solrizer::Fedora::Indexer.new
    end
     
    it "should return a URL from solr_config if the config has a 'url' " do
           Blacklight.stubs(:solr_config).returns({'url' => "http://foo.com:8080/solr"})
           @indexer = Solrizer::Fedora::Indexer.new
    end
     
    it "should return a URL from solr_config if the config has a 'url' " do
             Blacklight.stubs(:solr_config).returns({'boosh' => "http://foo.com:8080/solr"})
            lambda { Solrizer::Fedora::Indexer.new }.should raise_error(URI::InvalidURIError)         
    end
      
    it "should return a fulltext URL if solr_config has a fulltext url defined" do
          Blacklight.stubs(:solr_config).returns({'fulltext' =>{ 'url' => "http://foo.com:8080/solr"}})
          @indexer = Solrizer::Fedora::Indexer.new(:index_full_text => true)
    end
      
    it "should return a fulltext URL if solr_config has a default url defined" do
          Blacklight.stubs(:solr_config).returns({'default' =>{ 'url' => "http://foo.com:8080/solr"}})
           @indexer = Solrizer::Fedora::Indexer.new(:index_full_text => false)
    end
      
    #it "should find the solr.yml even if Blacklight is not loaded" do 
         #Module.remove_class(Blacklight)
         #YAML.stubs(:load).returns({'test' => {'url' => "http://thereisnoblacklightrunning.edu:8080/solr"}})
         #@indexer = Solrizer::Fedora::Indexer.new  
    #end
      
    it "should find the solr.yml even if Blacklight is not loaded and RAILS is not loaded" do 
           temp_rails_root = RAILS_ROOT
           Object.send(:remove_const, :RAILS_ROOT)
           YAML.stubs(:load).returns({'development' => {'url' => "http://noblacklight.norails.edu:8080/solr"}})
           @indexer = Solrizer::Fedora::Indexer.new  
           RAILS_ROOT = temp_rails_root
    end    
  end     
end
    