require 'spec_helper'
require "active_fedora"

describe VideoAsset do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @asset = VideoAsset.new
    @asset.stubs(:create_date).returns("2008-07-02T05:09:42.015Z")
    @asset.stubs(:modified_date).returns("2008-09-29T21:21:52.892Z")
  end
  
  it "Should be a kind of ActiveFedora::Base kind of FileAsset, and instance of VideoAsset" do
    @asset.should be_kind_of(ActiveFedora::Base)
    @asset.should be_kind_of(FileAsset)
    @asset.should be_instance_of(VideoAsset)
  end
  
  it "should have a conforms_to relationship pointing to FileAsset" do
    @asset.relationships[:self][:has_model].should include("info:fedora/afmodel:FileAsset")
  end
  
end