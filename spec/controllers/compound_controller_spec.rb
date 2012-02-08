require 'spec_helper'
require 'user_helper'

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

    describe "when signed in" do
      include UserHelper
      before do
        #sign_in FactoryGirl.find_or_create(:cat)
        cat_user_sign_in

        @test_file = fixture("image.jp2")
        filename = "My File Name"
				mime_type = "image/jp2"
        @test_file.expects(:original_filename).returns(filename)
				@test_file.expects(:content_type).returns(mime_type)
        @test_file.expects(:size).returns(2340)

      end
      it "should save the first file as content" do

        post :create, :id=>@obj.id, :Filedata=>[@test_file], :content_type=>'generic_content'
        response.should redirect_to edit_resource_path(@obj.id)
        assigns[:document_fedora].datastreams['content'].dsLabel.should == 'My File Name'
        assigns[:document_fedora].datastreams['content'].mimeType.should == 'application/octet-stream'
        assigns[:document_fedora].datastreams['contentMetadata'].content_url.should == ["http://test.host/assets/#{@obj.id}/datastreams/content"]
      end
      it "should save the second file as content02" do
        @obj.add_datastream(@obj.create_datastream(ActiveFedora::Datastream, 'content', :blob=>"hey"))
        @obj.save
        post :create, :id=>@obj.id, :Filedata=>[@test_file], :content_type=>'generic_content'
        response.should redirect_to edit_resource_path(@obj.id)
        assigns[:document_fedora].datastreams['content02'].dsLabel.should == 'My File Name'
        assigns[:document_fedora].datastreams['content02'].mimeType.should == 'application/octet-stream'
        assigns[:document_fedora].datastreams['contentMetadata'].content_url.should == ["http://test.host/assets/#{@obj.id}/datastreams/content02"]
      end
    end
  end

end
