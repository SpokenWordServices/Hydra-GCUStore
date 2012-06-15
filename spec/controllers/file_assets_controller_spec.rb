require 'spec_helper'

describe FileAssetsController do

  describe 'routes' do
    it "should have create" do
      {:post => "/assets/hull:3856/file_assets"}.should route_to(:controller=>'file_assets', :asset_id=>'hull:3856', :action=>'create')
    end
  end 
  
  describe 'create' do
      before :each do
        @test_container = UketdObject.new
        @test_container.add_relationship(:is_member_of, "info:fedora/foo:1")
        @test_container.add_relationship(:has_collection_member, "info:fedora/foo:2")
        @test_container.rightsMetadata.update_indexed_attributes([:edit_access, :person]=>'ralph')
        @test_container.update_indexed_attributes({[{:person=>0}, :institution]=>"my org"}, :datastreams=>"descMetadata")
        @test_container.save

				sign_in FactoryGirl.find_or_create(:cat)
        
        @test_file = fixture("small_file.txt")
        @filename = "My File Name"
        @test_file.expects(:original_filename).twice.returns("My File Name")
      end

      it "should update metadata" do
        controller.expects(:update_content_metadata)
        controller.expects(:update_desc_metadata)
        post :create, {:Filedata=>[@test_file], :Filename=>@filename, :container_id=>@test_container.pid}
        assigns["file_asset"].datastreams['rightsMetadata'].edit_access.machine.person.should == ["ralph"]
      end
  end

  describe 'destroy' do
    it "should delete the asset identified by pid" do
      mock_obj = mock("asset", :delete)
      ActiveFedora::Base.stubs(:load_instance).with("__PID__").returns(mock_obj)
      mock_metadata = mock('metadata', :serialize! => true)
      mock_container = mock("container", :remove_resource)
      mock_container.expects(:save)
      mock_container.expects(:contentMetadata).returns(mock_metadata)
      ActiveFedora::Base.stubs(:load_instance).with("__CONTAINER_ID__").returns(mock_container)
      ActiveFedora::ContentModel.stubs(:known_models_for).with( mock_container ).returns([])
      delete(:destroy, :id => "__PID__", :container_id=>"__CONTAINER_ID__")
    end
  end

  describe 'datastream' do
    it "should show the datastream" do
      mock_ds = mock("dc datastream", :content=>'DC content')
      mock_obj = stub("asset", :datastreams=>{'DC' => mock_ds })
      mock_obj.expects(:relationships).with(:has_model).returns(["info:fedora/afmodel:GenericContent"])
      ActiveFedora::Base.expects(:load_instance).with("__PID__").returns(mock_obj)
      GenericContent.expects(:load_instance).with("__PID__").returns(mock_obj)
      get :datastream, :id =>'__PID__', :datastream=>'DC'
      response.body.should == 'DC content'
    end
  end
  
end
