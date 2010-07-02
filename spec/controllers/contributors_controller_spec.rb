require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe ContributorsController do
  it "should support adding new person / contributor / organization nodes" do
    mock_document = mock("document")
    ["person","conference","organization"].each do |type|
      mock_document.expects("insert_contributor").with(type).returns(["foo node","foo index"])
      HydrangeaArticle.expects(:find).with("_PID_").returns(mock_document)
      post :create, :asset_id=>"_PID_", :controller => "contributors", :content_type => "hydrangea_article", :contributor_type=>type
      response.should render_template "hydrangea_articles/_edit_#{type}"
    end
  end
end
