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
  
end