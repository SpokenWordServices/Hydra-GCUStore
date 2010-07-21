require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe FileAsset do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
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
  
  describe ".add_file" do
    it "should call super.add_file"
    it "should set the FileAsset's title and label to the file datastream's filename if they are currently empty"
  end
end