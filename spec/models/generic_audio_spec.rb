require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe GenericAudio do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @hydra_image = GenericAudio.new

  end
  
  it "Should be a kind of ActiveFedora::Base" do
    @hydra_image.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should include Hydra Model Methods" do
    @hydra_image.class.included_modules.should include(Hydra::ModelMethods)
    @hydra_image.should respond_to(:apply_depositor_metadata)
  end
  
  it "should have accessors for its default content datastream" do
    @hydra_image.should respond_to(:has_content?)
    @hydra_image.should respond_to(:content)
    @hydra_image.should respond_to(:content=)
  end
  
 
  describe '#content=' do
    it "shoutld create a content datastream when given an audio file" do
    end
  end

  
end
