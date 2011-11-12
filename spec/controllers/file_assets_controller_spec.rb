require 'spec_helper'

#This file is testing FileAssetsController inside hydra, after FileAssetsControllerExtra has been mixed in by the hydra initializer.
describe FileAssetsController do

  
  describe 'create' do
      before :each do
        @test_container = ActiveFedora::Base.new
        @test_container.add_relationship(:is_member_of, "info:fedora/foo:1")
        @test_container.add_relationship(:has_collection_member, "info:fedora/foo:2")
        @test_container.save
        sign_in FactoryGirl.find_or_create(:cat)
        
        @test_file = fixture("small_file.txt")
        @filename = "My File Name"
        @test_file.expects(:original_filename).twice.returns("My File Name")
      end

      it "should set is_part_of relationship on the new File Asset pointing back at the container" do
        controller.expects(:update_metadata) ## This is what we're really testing for hull
        post :create, {:Filedata=>[@test_file], :Filename=>@filename, :container_id=>@test_container.pid}
      end
  end

  describe 'destroy' do
    it "should delete the asset identified by pid" do
      mock_obj = mock("asset", :delete)
      ActiveFedora::Base.expects(:load_instance).with("__PID__").returns(mock_obj)
      controller.expects(:update_metadata) ## This is what we're really testing for hull
      delete(:destroy, :id => "__PID__")
    end
  end
  
end
