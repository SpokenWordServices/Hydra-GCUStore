require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include StanfordSalt::SaltControllerHelper

describe StanfordSalt::SaltControllerHelper do
  
  describe "find_folder_siblings" do
    it "should search for siblings and put the result in @folder_siblings" do
      sample_document_info = {:series_facet=>["foo"], :box_facet=>["baz"], :folder_facet=>["bar"]}
      Blacklight.solr.expects(:find).with(:phrases => [{:series_facet => 'foo'}, {:box_facet => 'baz'}, {:folder_facet => 'bar'}]).returns("my result")
      find_folder_siblings( sample_document_info )
      @folder_siblings.should == "my result"
    end
    it "should set @folder_siblings to nil if the given document doesn't have folder, box & series info" do
      incomplete_info = {:series_facet=>"foo"}
      find_folder_siblings( incomplete_info )
      @folder_siblings.should be_nil
    end
  end
  
end