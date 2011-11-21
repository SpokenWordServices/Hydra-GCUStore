require 'spec_helper'


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe SubjectsController do
  describe 'routes' do
    it "should route subject_topic_path" do
      {:delete => '/subjects/1/2/3'}.should route_to(:controller=>'subjects', :action=>'destroy', :content_type=>'1', :asset_id=>'2', :index=>'3')
    end
  end

  describe "create" do
    it "should support adding new subject topic nodes" do
      pending "This routes to catalog controller"
      mock_document = mock("document")
      mock_document.expects(:insert_subject_topic).returns(["foo node","989"])
      mock_document.expects(:save)
      JournalArticle.expects(:find).with("_PID_").returns(mock_document)
      post :create, :asset_id=>"_PID_", :controller => "subjects", :content_type => "journal_article"
      response.should redirect_to "http://test.host/resources/_PID_/edit"
    end
  end
  
  describe "destroy" do
    it "should delete the subject topic corresponding to index" do
      mock_document = mock("JournalArticle")
      mock_document.expects(:remove_subject_topic).with("3")
      mock_document.expects(:save)
      JournalArticle.expects(:find).with("_PID_").returns(mock_document)
      
      delete :destroy, :asset_id=>"_PID_", :content_type => "journal_article", :index=>"3"
    end
  end
  
end
