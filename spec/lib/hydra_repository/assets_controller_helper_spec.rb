require File.expand_path( File.join( File.dirname(__FILE__), '..','..','spec_helper') )
  
class FakeAssetsController
  include Hydra::AssetsControllerHelper
end

def helper
  @fake_controller
end

describe Hydra::AssetsControllerHelper do

  before(:all) do
    @fake_controller = FakeAssetsController.new
  end
  
  describe "destringify" do
    it "should recursively change any strings beginning with : to symbols and any number strings to integers" do
      helper.destringify( [{":person"=>"0"}, ":last_name"] ).should == [{:person=>0}, :last_name]
      helper.destringify( [{"person"=>"3"}, "last_name"] ).should == [{:person=>3}, :last_name]
    end
  end
  
end