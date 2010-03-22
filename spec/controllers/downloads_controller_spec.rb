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
      @mock_pdf = mock("mock_pdf")
      @mock_pdf.stubs(:attributes).returns({"mimeType"=>"application/pdf"})
      @mock_pdf.stubs(:label).returns("my_document.pdf")
      @mock_pdf.stubs(:new_object?).returns(false) 
      
      @mock_ocr = mock("mock_ocr")
      @mock_ocr.stubs(:attributes).returns({"mimeType"=>"application/xml"})
      @mock_ocr.stubs(:label).returns("my_document_TEXT.xml") 
      @mock_ocr.stubs(:new_object?).returns(false) 
           
           
      @mock_mets = mock("mock_mets")
      @mock_mets.stubs(:attributes).returns({"mimeType"=>"application/xml"})
      @mock_mets.stubs(:label).returns("my_document_METS.xml")
      @mock_mets.stubs(:new_object?).returns(false) 
      
      @mock_image_xml1 = mock("mock_image_xml1")
      @mock_image_xml1.stubs(:attributes).returns({"mimeType"=>"application/xml"})
      @mock_image_xml1.stubs(:label).returns("my_document_0001.xml")
      @mock_image_xml1.stubs(:new_object?).returns(false) 
      
      @mock_image_xml2 = mock("mock_image_xml2")
      @mock_image_xml2.stubs(:attributes).returns({"mimeType"=>"application/xml"})
      @mock_image_xml2.stubs(:label).returns("my_document_0002.xml")
      @mock_image_xml2.stubs(:new_object?).returns(false) 
      
      @mock_ext_properties = mock("mock_ext_properties")
      @mock_ext_properties.stubs(:attributes).returns({"mimeType"=>"text/xml"})
      @mock_ext_properties.stubs(:label).returns("extProperties")
      @mock_ext_properties.stubs(:new_object?).returns(false) 
      
      
      @ds_hash = {"mock_pdf" => @mock_pdf, 
                "mock_ocr"=>@mock_ocr, 
                "ds13_id" => @mock_mets, 
                "mock_image_xml1"=>@mock_image_xml1, 
                "mock_image_xml2"=>@mock_image_xml2,
                "mock_ext_properties"=>@mock_ext_properties}
      @sample_object = mock("result_object", :datastreams => @ds_hash )
    end
    
    it "should default to returning only pdfs" do
      ActiveFedora::Base.expects(:load_instance).returns( @sample_object )
      xhr :get, :index, :document_id=>"_PID_", :wau=>"nobody"
      assigns(:datastreams).should == {"mock_pdf" => @mock_pdf}
    end

    it "should return a list of all datastreams if params[mime_type] == all and logged in as an editor" do
      ActiveFedora::Base.expects(:load_instance).returns( @sample_object )
      get :index, {:document_id=>"_PID_", :mime_type=>"all", :wau=>"francis"}
      assigns(:datastreams).should == @ds_hash
    end
    
    it "should default to returning pdfs, METS, and TEXT when logged in as an editor" do
      ActiveFedora::Base.expects(:load_instance).returns( @sample_object )
      xhr :get, :index, :document_id=>"_PID_", :wau=>"francis"
      assigns(:datastreams).should == {"mock_pdf" => @mock_pdf, 
                "mock_ocr"=>@mock_ocr, 
                "ds13_id" => @mock_mets}
    end
  end
  
  describe "index with download_id" do
    it "should return the specified datastream if given a download_id (datastream dsid)" do
      #Fedora::Repository.any_instance.expects(:fetch_custom).with("_PID_", "datastreams/my_datastream.pdf/content").returns("foo")
      mock_ds = mock("datastream", :label=>"mylabel", :content=>"ds content", :attributes=>{"mimeType"=>"text/plain"})
      ActiveFedora::Base.expects(:load_instance).returns(mock("result_object", :datastreams => {"mydsid"=>mock_ds}))
    
      controller.expects(:send_data).with("ds content", :filename=>"mylabel", :type => 'text/plain') #.returns("foo")
      get :index, :document_id=>"_PID_", :download_id=>"mydsid"
    end
  end
  
  
end