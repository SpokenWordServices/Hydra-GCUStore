require 'spec_helper'

describe ModsJournalArticle do
  describe "to_solr" do
    before do 
      @doc = ModsJournalArticle.from_xml(nil)
      @doc.title_info.main_title = "Foo"
      @doc.journal.title_info.main_title = "Bar"
    end
    it "should only have one title_facet in the solr doc" do
      ### When a solr field has many terms, then solr can not use it for sort by 
#      @doc.title_info.main_title.should == ["Foo"]
      @doc.to_solr['title_facet'].should == ["Foo"]
      
    end
  end


end
