require 'spec_helper'

#This file is testing FileAssetsController inside hydra, after FileAssetsControllerExtra has been mixed in by the hydra initializer.
describe FileAssetsController do

  before do
    session[:user]='bob'
    @controller.stubs(:update_metadata)
  end

  ## Plugin Tests
  it "should use FileAssetsController" do
    controller.should be_an_instance_of(FileAssetsController)
  end
  it "should be restful" do
    {:get => '/file_assets'}.should route_to(:controller=>'file_assets', :action=>'index')
    {:get => '/file_assets/3'}.should route_to(:controller=>'file_assets', :action=>'show', :id=>"3")
    {:delete => '/file_assets/3'}.should route_to(:controller=>'file_assets', :action=>'destroy', :id=>"3")
    {:put => '/file_assets/3'}.should route_to(:controller=>'file_assets', :action=>'update', :id=>"3")
    {:get => '/file_assets/3/edit'}.should route_to(:controller=>'file_assets', :action=>'edit', :id=>"3")
    {:get => '/file_assets/new'}.should route_to(:controller=>'file_assets', :action=>'new')
    {:post => '/file_assets'}.should route_to(:controller=>'file_assets', :action=>'create')
  end
  
  describe "index" do
    
    it "should find all file assets in the repo if no container_id is provided" do
      #FileAsset.expects(:find_by_solr).with(:all, {}).returns("solr result")
      # Solr::Connection.any_instance.expects(:query).with('conforms_to_field:info\:fedora/afmodel\:FileAsset', {}).returns("solr result")
      Solr::Connection.any_instance.expects(:query).with('active_fedora_model_s:FileAsset', {}).returns("solr result")


      ActiveFedora::Base.expects(:new).never
      xhr :get, :index
      response.should be_success
      assigns[:solr_result].should == "solr result"
    end
    it "should find all file assets belonging to a given container object if container_id or container_id is provided" do
      mock_container = mock("container")
      mock_container.expects(:file_objects).with(:response_format => :solr).returns("solr result")
      controller.expects(:get_solr_response_for_doc_id).with("_PID_").returns(["container solr response","container solr doc"])
      ActiveFedora::Base.expects(:load_instance).with("_PID_").returns(mock_container)
      xhr :get, :index, :container_id=>"_PID_"
      assigns[:response].should == "container solr response"
      assigns[:document].should == "container solr doc"
      assigns[:solr_result].should == "solr result"
      assigns[:container].should == mock_container
    end
    
    it "should find all file assets belonging to a given container object if container_id or container_id is provided" do
      pending
      # this was testing a hacked version
      mock_solr_hash = {"has_collection_member_field"=>["info:fedora/foo:id"]}
      mock_container = mock("container")
      mock_container.expects(:collection_members).with(:response_format=>:solr).returns("solr result")
      ActiveFedora::Base.expects(:load_instance).with("_PID_").returns(mock_container)
      #ActiveFedora::Base.expects(:find_by_solr).returns(mock("solr result", :hits => [mock_solr_hash]))
      #Solr::Connection.any_instance.expects(:query).with('id:foo\:id').returns("solr result")
      xhr :get, :index, :container_id=>"_PID_"
      assigns[:solr_result].should == "solr result"
      assigns[:container].should == mock_container
    end
  end

  describe "index" do
    before(:each) do
      Fedora::Repository.stubs(:instance).returns(stub_everything)
    end

    it "should be refined further!"
    
  end
  describe "new" do
    it "should return the file uploader view"
    it "should set :container_id to value of :container_id if available" do
      xhr :get, :new, :container_id=>"_PID_"
      params[:container_id].should == "_PID_"
    end
  end

  describe "show" do
    it "should redirect to index view if current_user does not have read or edit permissions" do
      mock_user = mock("User")
      mock_user.stubs(:login).returns("fake_user")
      mock_user.stubs(:is_being_superuser?).returns(false)
      controller.stubs(:current_user).returns(mock_user)
      get(:show, :id=>"hydrangea:fixture_file_asset1")
      response.should redirect_to(:action => 'index')
    end
    it "should redirect to index view if the file does not exist" do
      get(:show, :id=>"example:invalid_object")
      response.should redirect_to(:action => 'index')
    end
  end
  
  describe "create" do
    it "should init solr, create a FileAsset object, add the uploaded file to its datastreams, set the filename as its title, label, and the datastream label, and save the FileAsset" do
      ActiveFedora::SolrService.stubs(:register)
      mock_file = mock("File")
      filename = "Foo File"
      mock_fa = mock("FileAsset", :save)
      FileAsset.expects(:new).returns(mock_fa)
      mime_type = "application/octet-stream"
      #updated expectation for hull
      mock_fa.expects(:add_file_datastream).with(mock_file, :label=>filename, :mimeType=>mime_type, :dsid=>"content")
      mock_fa.expects(:label=).with(filename)
      mock_fa.stubs(:pid).returns("foo:pid")
      xhr :post, :create, :Filedata=>mock_file, :Filename=>filename
    end
    it "if container_id is provided, should initialize a Base stub of the container, add the file asset to its relationships, and save both objects" do
      mock_file = mock("File")
      filename = "Foo File"
      mock_fa = mock("FileAsset", :save)
      mock_fa.stubs(:pid).returns("foo:pid")
      FileAsset.expects(:new).returns(mock_fa)
      mime_type = "application/octet-stream"
      # updated expecation for hull - passing in dsid
      mock_fa.expects(:add_file_datastream).with(mock_file, :label=>filename, :mimeType=>mime_type,:dsid=>"content")
#mock_fa.expects(:add_file_datastream).with(mock_file, :label=>filename)
      mock_fa.expects(:label=).with(filename)
      

#      mock_fa.expects(:fields)
      mock_fa.stubs(:fields)

      mock_container = mock("container")
      mock_container.expects(:file_objects_append).with(mock_fa) 
      mock_container.expects(:save)
      #mock_container.expects(:rels_ext).returns(mock("rels-ext", :save))
      ActiveFedora::Base.expects(:load_instance).with("_PID_").returns(mock_container)
      # added for hull
      mock_resp = mock("Response")
      mock_resp.stubs(:hits).returns([])
      FileAsset.expects(:find_by_fields_by_solr).returns(mock_resp)
      mock_container.expects(:pid).returns("_PID_")
      
      xhr :post, :create, :Filedata=>mock_file, :Filename=>filename, :container_id=>"_PID_"
    end
    
    it "should attempt to guess at type and set model accordingly" do
      pending "THIS TEST's EXPECTATIONS ARE BLEEDING OVER AND BREAKING OTHER TESTS"
      FileAsset.expects(:new).never
      AudioAsset.expects(:new).times(3).returns(stub_everything)

      post :create, :Filename=>"meow.mp3", :Filedata=>"boo"
      post :create, :Filename=>"meow.wav", :Filedata=>"boo"
      post :create, :Filename=>"meow.aiff", :Filedata=>"boo"
      
      VideoAsset.expects(:new).times(2).returns(stub_everything)
      
      post :create, :Filename=>"meow.mov", :Filedata=>"boo"
      post :create, :Filename=>"meow.flv", :Filedata=>"boo"
      
      ImageAsset.expects(:new).times(4).returns(stub_everything)
      
      post :create, :Filename=>"meow.jpg", :Filedata=>"boo"
      post :create, :Filename=>"meow.jpeg", :Filedata=>"boo"
      post :create, :Filename=>"meow.png", :Filedata=>"boo"
      post :create, :Filename=>"meow.gif", :Filedata=>"boo"

    end    
  end

  describe "destroy" do
    it "should delete the asset identified by pid" do
      mock_obj = mock("asset", :delete)
      ActiveFedora::Base.expects(:load_instance).with("__PID__").returns(mock_obj)
      delete(:destroy, :id => "__PID__")
    end
    it "should remove container relationship and perform proper garbage collection" do
      pending "relies on ActiveFedora implementing Base.file_objects_remove"
      mock_container = mock("asset")
      mock_container.expects(:file_objects_remove).with("_file_asset_pid_")
      FileAsset.expects(:garbage_collect).with("_file_asset_pid_")
      ActiveFedora::Base.expects(:load_instance).with("_container_pid_").returns(mock_container)
      delete(:destroy, :id => "_file_asset_pid_", :container_id=>"_container_pid_")
    end
  end
  
  describe "integration tests - " do
    before(:all) do
      ActiveFedora::SolrService.register(ActiveFedora.solr_config[:url])
      @test_container = ActiveFedora::Base.new
      @test_container.add_relationship(:is_member_of, "info:fedora/foo:1")
      @test_container.add_relationship(:has_collection_member, "info:fedora/foo:2")
      @test_container.save
      
      @test_fa = FileAsset.new
      @test_fa.add_relationship(:is_part_of, @test_container)
      @test_fa.save
    end

    after(:all) do
     @test_container.delete
     @test_fa.delete
    end

    describe "index" do
      it "should retrieve the container object and its file assets" do
        #xhr :get, :index, :container_id=>@test_container.pid
        get :index, {:container_id=>@test_container.pid}
        assigns(:solr_result).should_not be_nil
        #puts assigns(:solr_result).inspect
        assigns(:container).file_objects(:response_format=>:id_array).should include(@test_fa.pid)
        assigns(:container).file_objects(:response_format=>:id_array).should include("foo:2")
      end
    end
    
    describe "create" do
      it "should set is_part_of relationship on the new File Asset pointing back at the container" do
        @controller.stubs(:next_asset_pid).returns(nil)
        test_file = fixture("empty_file.txt")
        filename = "My File Name"
        post :create, {:Filedata=>test_file, :Filename=>filename, :container_id=>@test_container.pid}
        assigns(:file_asset).relationships[:self][:is_part_of].should == ["info:fedora/#{@test_container.pid}"] 
        retrieved_fa = FileAsset.load_instance(@test_fa.pid).relationships[:self][:is_part_of].should == ["info:fedora/#{@test_container.pid}"]
      end
      it "should retain previously existing relationships in container object" do
        @controller.stubs(:next_asset_pid).returns(nil)
        test_file = fixture("empty_file.txt")
        filename = "My File Name"
        post :create, {:Filedata=>test_file, :Filename=>filename, :container_id=>@test_container.pid}
        assigns(:container).collection_members(:response_format=>:id_array).should include("foo:2")
      end
    end
  end
end
