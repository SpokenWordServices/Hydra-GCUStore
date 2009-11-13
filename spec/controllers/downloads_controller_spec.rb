require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'mocha'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe DownloadsController do
  
  before do
    #controller.stubs(:protect_from_forgery).returns("meh")
    session[:user]='bob'
  end
  
  it "should use DownloadsController" do
    controller.should be_an_instance_of(DownloadsController)
  end
  
  it "should be restful" do
    #route_for(:controller=>'courses', :action=>'index').should == '/'
    route_for(:controller=>'downloads', :action=>'index', :document_id=>"_PID_").should == '/documents/_PID_/downloads'
    #route_for(:controller=>'downloads', :action=>'show', :document_id=>"_PID_", :id=>"my_datastream.pdf").should == '/documents/_PID_/downloads/my_datastream.pdf'

    params_from(:get, '/documents/_PID_/downloads').should == {:controller=>'downloads', :document_id=>"_PID_", :action=>'index'}
    #params_from(:get, '/documents/_PID_/downloads/3.pdf').should == {:controller=>'downloads', :document_id=>"_PID_",  :action=>'show', :id=>'3.pdf'}
    #params_from(:get, '/documents/_PID_/downloads/3').should == {:controller=>'downloads', :document_id=>"_PID_",  :action=>'show', :id=>'3'}

  end
  
  describe "index" do
    
    before(:each) do
      mock_repo = mock('repo')
      Fedora::Repository.expects(:register).returns(mock_repo)
    end
    
    it "should create a stub of the specified document and return its datastreams list hash by calling its .datastreams method" do
      ActiveFedora::Base.expects(:load_instance).returns(mock("result_object", :datastreams => ["ds1_id" => "ds1", "ds2_id"=>"ds2"]))
      xhr :get, :index, :document_id=>"_PID_"
      assigns(:datastreams).should == ["ds1_id" => "ds1", "ds2_id"=>"ds2"]
    end
    
    it "should return the specified datastream if given a download_id (datastream dsid)" do
      #Fedora::Repository.any_instance.expects(:fetch_custom).with("_PID_", "datastreams/my_datastream.pdf/content").returns("foo")
      mock_ds = mock("datastream", :label=>"mylabel", :content=>"ds content", :attributes=>{"mimeType"=>"text/plain"})
      ActiveFedora::Base.expects(:load_instance).returns(mock("result_object", :datastreams => {"mydsid"=>mock_ds}))
      
      controller.expects(:send_data).with("ds content", :filename=>"mylabel", :type => 'text/plain') #.returns("foo")
      get :index, :document_id=>"_PID_", :download_id=>"mydsid"
    end
  end
  
  
end