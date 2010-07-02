require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"
require "nokogiri"

describe Hydra::RightsMetadata do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @sample = Hydra::RightsMetadata.new
  end
  
  describe "update_indexed_attributes" do
    it "should update the declared properties" do
      @sample.retrieve(*[:edit_access, :person]).length.should == 0
      @sample.update_properties([:edit_access, :person]=>"user id").should == {"edit_access_person"=>{"0"=>"user id"}}
      @sample.retrieve(*[:edit_access, :person]).length.should == 1
      @sample.retrieve(*[:edit_access, :person]).first.text.should == "user id"
    end
  end
end