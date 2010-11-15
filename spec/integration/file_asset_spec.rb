require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe FileAsset do
  before(:each) do
    @file_asset = FileAsset.new
    @asset1 = ActiveFedora::Base.new
    @asset2 = ActiveFedora::Base.new
    @asset3 = ActiveFedora::Base.new
    @asset1.save
    @asset2.save
    @asset3.save
  end

  after(:each) do
    begin
    @file_asset.delete
    rescue
    end
    begin
    @asset1.delete
    rescue
    end
    begin
    @asset2.delete
    rescue
    end
    begin
    @asset3.delete
    rescue
    end
  end

  describe ".containers" do    
    it "should return asset container objects via either inbound has_collection_member, inbound has_part, or outbound is_part_of relationships" do
      #test all possible combinations...
      #none
      @file_asset.containers(:response_format=>:id_array).should == []
      #is_part_of
      @file_asset.part_of_append(@asset1)
      @file_asset.containers(:response_format=>:id_array).should == [@asset1.pid]
      #has_part + is_part_of
      @asset2.parts_append(@file_asset)
      @asset2.save
      @file_asset.containers(:response_format=>:id_array).should == [@asset2.pid,@asset1.pid]
      #has_part
      @file_asset.part_of_remove(@asset1)
      @file_asset.containers(:response_format=>:id_array).should == [@asset2.pid]      
      #has_collection_member
      @asset2.parts_remove(@file_asset)
      @asset2.save
      @asset3.collection_members_append(@file_asset)
      @asset3.save
      @file_asset.containers(:response_format=>:id_array).should == [@asset3.pid]
      #is_part_of + has_collection_member
      @file_asset.part_of_append(@asset1)
      @file_asset.containers(:response_format=>:id_array).should == [@asset3.pid,@asset1.pid]
      #has_part + has_collection_member      
      @file_asset.part_of_remove(@asset1)
      @asset2.parts_append(@file_asset)
      @asset2.save
      @file_asset.containers(:response_format=>:id_array).should == [@asset3.pid,@asset2.pid]
      #has_collection_member + has_part + is_part_of
      @file_asset.part_of_append(@asset1)
      @file_asset.containers(:response_format=>:id_array).should == [@asset3.pid,@asset2.pid,@asset1.pid]
    end
  end

  describe ".containers_ids" do
    it "should return an array of container ids instead of objects" do
       #test all possible combinations...
      #none
      @file_asset.containers_ids.should == []
      #is_part_of
      @file_asset.part_of_append(@asset1)
      @file_asset.containers_ids.should == [@asset1.pid]
    end
  end
end
