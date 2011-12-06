require 'spec_helper'

describe CompoundController do
  it "should have routes" do
    compound_upload_path(66).should == "/compound/66"
    {:post=>'/compound/57'}.should route_to(:controller=>'compound', :action=>'create', :id=>"57")
  end
  describe "show" do
    it "should redirect to assets#show" do
      get :show, :id=>7
      response.should redirect_to resources_path(7)
    end
  end

  describe "create" do
    before do
      @obj = GenericContent.new
      @obj.rightsMetadata.edit_access.machine.group= 'contentAccessTeam'
      @obj.genre= 'Policy or procedure'
      @obj.save
    end
    it "should redirect when no user is signed in" do
      post :create, :id=>@obj.id, :Filedata=>[fixture_file_upload('spec/fixtures/image.jp2')]
      response.should redirect_to compound_path(@obj.id)
    end
    it "should save the file" do
      sign_in FactoryGirl.find_or_create(:cat)
      test_file = fixture("image.jp2")
      filename = "My File Name"
      test_file.expects(:original_filename).returns(filename)
      test_file.expects(:size).returns(2340)

      post :create, :id=>@obj.id, :Filedata=>[test_file], :content_type=>'generic_content'
      response.should redirect_to edit_resource_path(@obj.id)
      assigns[:document_fedora].datastreams['content1'].dsLabel.should == 'My File Name'
      assigns[:document_fedora].datastreams['content1'].mimeType.should == 'application/octet-stream'
      assigns[:document_fedora].datastreams['contentMetadata'].content_url.should == ["http://test.host/assets/#{@obj.id}/datastreams/content1"]
    end
  end

end
