require 'spec_helper'
  
class FakeAssetsController < ApplicationController
  include Hull::AssetsControllerHelper
end

def helper
  @fake_controller
end

describe Hull::AssetsControllerHelper do

  before(:all) do
    @fake_controller = FakeAssetsController.new
  end

  describe "add_implied_params" do
    before do
      @sanitized_params = { "descMetadata" => { [:rights_label] => {"0"=>"My Licence"}, :title =>"Test title"}, "properties"=>{:notes=>"Some notes"}}
      helper.instance_variable_set :@sanitized_params, @sanitized_params
    end
    it "should check the chosen licence exists and copy the associated data" do 
      mock_licence = Licence.create(:name =>"My Licence", :description=>"blah", :link=>"http://fake.link")
      Licence.expects(:find_by_name).with("My Licence").returns(mock_licence)
      helper.add_implied_params
      @sanitized_params["descMetadata"][[:rights]].should == {"0"=>"blah"}
      @sanitized_params["descMetadata"][[:rights_url]].should == {"0"=>"http://fake.link"}
    end
  end 
  

end
