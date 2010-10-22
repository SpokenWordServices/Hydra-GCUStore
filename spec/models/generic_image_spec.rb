require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe GenericImage do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub_everything())
    @hydra_image = GenericImage.new

  end
  
  it "Should be a kind of ActiveFedora::Base" do
    @hydra_image.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should include Hydra Model Methods" do
    @hydra_image.class.included_modules.should include(Hydra::ModelMethods)
    @hydra_image.should respond_to(:apply_depositor_metadata)
  end
  
  it "should have accessors for its default datastreams of content and original" do
    @hydra_image.should respond_to(:has_content?)
    @hydra_image.should respond_to(:content)
    @hydra_image.should respond_to(:content=)
    @hydra_image.should respond_to(:has_original?)
    @hydra_image.should respond_to(:original)
    @hydra_image.should respond_to(:original=)
  end
  
  it "should have accessors for its default datastreams of max, screen and thumbnail" do
    @hydra_image.should respond_to(:has_max?)
    @hydra_image.should respond_to(:max)
    @hydra_image.should respond_to(:max=)
    @hydra_image.should respond_to(:has_screen?)
    @hydra_image.should respond_to(:screen)
    @hydra_image.should respond_to(:screen=)
    @hydra_image.should respond_to(:has_thumbnail?)
    @hydra_image.should respond_to(:thumbnail)
    @hydra_image.should respond_to(:thumbnail=)
  end
  
  describe '#content=' do
    it "create a content datastream when given an image file" do
      mock_datastream = mock("content datastream")
      #mock_image.expects(:derive_all)
      
      Fedora::Repository.expects(:do_method).returns(mock_datastream)
      f = File.new("#{Rails.root}/spec/fixtures/image.tiff")
      @hydra_image.content=f
      
      
      
      #mock_orphan = mock("orphan file asset", :containers=>[])
      #mock_orphan.expects(:delete)
      #HydraImage.stub(:load_instance).and_return(mock_image)  
      #HydraImage.expects(:load_instance).with("_hydra_image_pid_").returns(mock_image)
      #FileAsset.expects(:load_instance).with("_orphan_pid_").returns(mock_orphan)
      
      
      
      #FileAsset.garbage_collect("_non_orphan_pid_")
      #FileAsset.garbage_collect("_orphan_pid_")
    end
  end
  
end