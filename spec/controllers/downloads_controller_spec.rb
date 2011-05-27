require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'mocha'

describe DownloadsController do
  
  before do
    session[:user]='bob'
  end
  
  it "should use DownloadsController" do
    controller.should be_an_instance_of(DownloadsController)
  end
  
  it "should be restful" do
    route_for(:controller=>'downloads', :action=>'index', :asset_id=>"_PID_", :download_id=>"content").should == '/assets/_PID_/content'

    params_from(:get, '/assets/_PID_/content').should == {:controller=>'downloads', :asset_id=>"_PID_", :action=>"index",:download_id=>"content"}
  end
 
  describe "index" do
    it "should return the content of the given datastream for the object identified by the asset_id" do
      mock_ds = mock("pdf datastream", :content=>"pdf content")
      mock_ds.expects(:attributes).times(2).returns({"mimeType"=>"application/pdf"})
      result_object = mock("result_object",:pid => "foo:pid")
      result_object.stubs(:datastreams).returns({"content"=>mock_ds})
      ActiveFedora::Base.expects(:load_instance).returns(result_object)
     
      controller.expects(:send_data).with("pdf content",:filename=>"content-foo_pid.pdf", :type=>"application/pdf")
      get :index, :asset_id=>"foo:pid", :download_id=>"content"
    end

  end

  describe "filename_from_datastream_name_and_mime_type" do
    it "should should return appropriate filenames" do
      controller.send(:filename_from_datastream_name_and_mime_type,"foo:pid","bar","application/pdf").should == "bar-foo_pid.pdf"
      controller.send(:filename_from_datastream_name_and_mime_type,"foo:pid","bar","video/x-ms-wmv").should == "bar-foo_pid.wmv"
      controller.send(:filename_from_datastream_name_and_mime_type,"foo:pid","bar","text/plain").should == "bar-foo_pid.txt"
      controller.send(:filename_from_datastream_name_and_mime_type,"foo:pid","bar","text/xml").should == "bar-foo_pid.xml"
      controller.send(:filename_from_datastream_name_and_mime_type,"foo:pid","bar","image/tiff").should == "bar-foo_pid.tiff"
    end
  end

#  describe "show" do
#    it "should return the content of the first PDF datastream for the object identified by download_id" do
#      #Fedora::Repository.any_instance.expects(:fetch_custom).with("_PID_", "datastreams/my_datastream.pdf/content").returns("foo")
#      mock_ds = mock("pdf1 datastream", :label=>"first.pdf", :content=>"pdf1 content", :attributes=>{"mimeType"=>"application/pdf"})
#      result_object = mock("result_object")
#      ActiveFedora::Base.expects(:load_instance).returns(result_object)
#      controller.expects(:downloadables).with(result_object, :canonical=>true).returns(mock_ds)
#      controller.expects(:send_data).with("pdf1 content", :filename=>"first.pdf", :type => "application/pdf") #.returns("foo")
#      get :show, :id=>"_PID_"
#    end
#    
#    it "should return canonical pdf as response to .pdf requests" do
#      result_object = mock("result_object")
#      ActiveFedora::Base.expects(:load_instance).returns(result_object)
#      mock_ds = mock("pdf1 datastream", :label=>"first.pdf", :content=>"pdf1 content", :attributes=>{"mimeType"=>"application/pdf"})
#      
#      controller.expects(:downloadables).with(result_object, :canonical=>true, :mime_type=>"application/pdf").returns(mock_ds)
#      controller.expects(:send_data).with("pdf1 content", :filename=>"first.pdf", :type => "application/pdf") #.returns("foo")
#      get :show, :id=>"_PID_", :format=>"pdf"
#    end
#    it "should return canonical jpeg2000 as response to .jp2 requests" do
#      result_object = mock("result_object")
#      ActiveFedora::Base.expects(:load_instance).returns(result_object)
#      mock_ds = mock("jp2 datastream", :label=>"first.jp2", :content=>"jp2 content", :url=>"jp2_url", :attributes=>{"mimeType"=>"image/jp2"})
#      
#      controller.expects(:downloadables).with(result_object, :canonical=>true, :mime_type=>"image/jp2").returns(mock_ds)
#      controller.expects(:send_data).with("jp2 content", :filename=>"first.jp2", :type => "image/jp2") #.returns("foo")
#      get :show, :id=>"_PID_", :format=>"jp2"
#    end
#    it "should support using djatoka with canonical jpeg2000" do
#      result_object = mock("result_object")
#      ActiveFedora::Base.expects(:load_instance).returns(result_object)
#      mock_ds = mock("jp2 datastream", :url=>"mock_jp2_url")
#            
#      controller.expects(:downloadables).with(result_object, :canonical=>true, :mime_type=>"image/jp2").returns(mock_ds)
#      Djatoka.expects(:get_image).returns("djatoka result")
#      controller.expects(:send_data).with( "djatoka result", :type=>"image/jpeg"  )
#      get :show, :id=>"_PID_", :format=>"jp2", :image_server=>"true"
#    end
#    it "should support using djatoka with canonical jpeg2000" do
#      result_object = mock("result_object")
#      ActiveFedora::Base.expects(:load_instance).returns(result_object)
#      mock_ds = mock("jp2 datastream", :url=>"mock_jp2_url")
#      
#      controller.expects(:downloadables).with(result_object, :canonical=>true, :mime_type=>"image/jp2").returns(mock_ds)
#      Djatoka.expects(:scale).with("mock_jp2_url/content", "96").returns("djatoka result")
#      controller.expects(:send_data).with( "djatoka result", :type=>"image/jpeg" )
#      get :show, :id=>"_PID_", :format=>"jp2", :image_server=>{:scale=>"96"}
#    end
#  end
  
  
end
