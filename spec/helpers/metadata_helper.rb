require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MetadataHelper do
  
  before(:all) do
    @mock_ng_ds = mock("nokogiri datastream")
    @mock_ng_ds.stubs(:kind_of?).with(ActiveFedora::NokogiriDatastream).returns(true)
    @mock_ng_ds.stubs(:class).returns(ActiveFedora::NokogiriDatastream)
    datastreams = {"ds1"=>@mock_ng_ds}
    @resource = mock("fedora object")
    @resource.stubs(:datastreams).returns(datastreams)
  end
  
  describe "get_values_from_datastream" do
    it "(with nokogiri datastreams) should call lookup with field_name and returns the text values from each resulting node" do
      @mock_ng_ds.expects(:property_values).with("--my xpath--").returns(["value1", "value2"])
      helper.get_values_from_datastream(@resource, "ds1", "--my xpath--").should == ["value1", "value2"]
    end
    it "should assume symbols and arrays are pointers to accessors declared in this datastream's model" do
      
      ActiveFedora::NokogiriDatastream.expects(:accessor_xpath).with(:abstract).returns("--abstract xpath--")
      ActiveFedora::NokogiriDatastream.expects(:accessor_xpath).with([{:person=>1}]).returns("--person xpath--")
      ActiveFedora::NokogiriDatastream.expects(:accessor_xpath).with([{:person=>1},{:role=>1},:text]).returns("--person role text xpath--")     
      
      @mock_ng_ds.expects(:property_values).with("--abstract xpath--").returns(["abstract1", "abstract2"])
      @mock_ng_ds.expects(:property_values).with("--person xpath--").returns(["person1", "person2"])
      @mock_ng_ds.expects(:property_values).with("--person role text xpath--").returns(["text1"])
      
      helper.get_values_from_datastream(@resource, "ds1", :abstract).should == ["abstract1", "abstract2"]
      helper.get_values_from_datastream(@resource, "ds1", {:person=>1}).should == ["person1", "person2"]
      helper.get_values_from_datastream(@resource, "ds1", [{:person=>1},{:role=>1},:text]).should == ["text1"]

    end
  end


end