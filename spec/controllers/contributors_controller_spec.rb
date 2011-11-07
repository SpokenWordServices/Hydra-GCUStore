require 'spec_helper'


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe ContributorsController do
  
  describe "create" do
    it "should support adding new person / contributor / organization nodes" do
      mock_document = mock("document")
      ["person","conference","organization"].each do |type|
        mock_document.expects(:insert_contributor).with(type).returns(["foo node","989"])
        mock_document.expects(:save)
        HydrangeaArticle.expects(:find).with("_PID_").returns(mock_document)
        post :create, :asset_id=>"_PID_", :controller => "contributors", :content_type => "hydrangea_article", :contributor_type=>type
        response.should redirect_to "http://test.host/resources/_PID_/edit##{type}_989"
      end
    end
  end
  
  describe "destroy" do
    it "should delete the contributor corresponding to contributor_type and index" do
      mock_dataset = mock("Dataset")
      mock_dataset.expects(:remove_contributor).with("conference", "3")
      mock_dataset.expects(:save)
      HydrangeaDataset.expects(:find).with("_PID_").returns(mock_dataset)
      
      delete :destroy, :asset_id=>"_PID_", :content_type => "hydrangea_dataset", :contributor_type=>"conference", :index=>"3"
    end
  end
  
end
