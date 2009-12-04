require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'mocha'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe GetController do
  
  before do
    #controller.stubs(:protect_from_forgery).returns("meh")
    session[:user]='bob'
  end
  
  it "should use DownloadsController" do
    controller.should be_an_instance_of(GetController)
  end
  
  it "should be restful" do
    #route_for(:controller=>'courses', :action=>'index').should == '/'
    route_for(:controller=>'get', :action=>'show', :document_id=>"_PID_").should == '/get/_PID_'
    # route_for(:controller=>'get', :action=>'show', :document_id=>"_PID_").should == '/get/_PID_.pdf'

    params_from(:get, '/get/_PID_').should == {:controller=>'get', :document_id=>"_PID_", :action=>'show'}
    # params_from(:get, '/get/_PID_.pdf').should == {:controller=>'get', :document_id=>"_PID_", :action=>'show'}

  end
  
  describe "show" do
    it "should return the content of the first PDF datastream for the object identified by download_id" do
      #Fedora::Repository.any_instance.expects(:fetch_custom).with("_PID_", "datastreams/my_datastream.pdf/content").returns("foo")
      first_pdf = mock("pdf1 datastream", :label=>"first.pdf", :content=>"pdf1 content", :attributes=>{"mimeType"=>"application/pdf"})
      second_pdf = mock("pdf2 datastream")
      result_object = mock("result_object")
      ActiveFedora::Base.expects(:load_instance).returns(result_object)
      controller.expects(:downloadables).with(result_object, :canonical=>true).returns(first_pdf)
      controller.expects(:send_data).with("pdf1 content", :filename=>"first.pdf", :type => "application/pdf") #.returns("foo")
      get :show, :document_id=>"_PID_"
    end
  end
  
  
end