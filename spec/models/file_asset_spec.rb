require 'spec_helper'


#This file is testing FileAsset inside hydra, after FileAssetExtra has been mixed in by the hydra initializer.

describe FileAsset do
  
  before(:each) do
    @file_asset = FileAsset.new
    @file_asset.stubs(:create_date).returns("2008-07-02T05:09:42.015Z")
    @file_asset.stubs(:modified_date).returns("2008-09-29T21:21:52.892Z")
  end
  
  it "Should be a kind of ActiveFedora::Base" do
    @file_asset.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should include Hydra Model Methods" do
    @file_asset.class.included_modules.should include(Hydra::ModelMethods)
    @file_asset.should respond_to(:apply_depositor_metadata)
  end
  
  describe '#garbage_collect' do
    it "should delete the object if it does not have any objects asserting has_collection_member" do
      #mock_non_orphan = mock("non-orphan file asset", :containers=>["foo"])
      mock_non_orphan = mock("non-orphan file asset")
      mock_non_orphan.expects(:delete).never
      
      #mock_orphan = mock("orphan file asset", :containers=>[])
      mock_orphan = mock("orphan file asset")
      mock_orphan.expects(:delete).never

      FileAsset.expects(:load_instance).with("_non_orphan_pid_").returns(mock_non_orphan).never
      FileAsset.expects(:load_instance).with("_orphan_pid_").returns(mock_orphan).never  
    end
  end
  
  describe ".add_file" do
    it "should call super.add_file"
    it "should set the FileAsset's title and label to the file datastream's filename if they are currently empty"
  end

  describe ".to_solr" do
    it "should solrize a parent object if it exists" do
      mock_parent = mock("parent")
      mock_parent.stubs(:pid).returns("_PID_")
      mock_content_ds = mock("content_ds")
      mock_content_ds.expects(:mimeType).returns("application/pdf")
      @file_asset.stubs(:datastreams).returns({"content"=>mock_content_ds})
      @file_asset.expects(:part_of).at_least_once.returns([mock_parent])
      mock_solrizer = mock("solrizer")
      mock_solrizer.expects(:solrize).with(mock_parent)
      Solrizer::Fedora::Solrizer.expects(:new).returns( mock_solrizer )
      @file_asset.to_solr
    end
  end
end
