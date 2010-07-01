require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MetadataHelper do
  
  before(:all) do
    @mock_ng_ds = mock("nokogiri datastream")
    @mock_ng_ds.stubs(:kind_of?).with(ActiveFedora::NokogiriDatastream).returns(true)
    @mock_ng_ds.stubs(:class).returns(ActiveFedora::NokogiriDatastream)
    @mock_md_ds = stub(:stream_values=>"value")
    datastreams = {"ng_ds"=>@mock_ng_ds,"simple_ds"=>@mock_md_ds}
    @resource = mock("fedora object")
    @resource.stubs(:datastreams).returns(datastreams)
    @resource.stubs(:datastreams_in_memory).returns(datastreams)
        
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "first_name").returns( ["Bob"] )
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "last_name").returns( ["Bob","Bill"] )
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "abstract").returns( ["Textile1","Textile2"] )
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "drop_down").returns( ["Value1"] )
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "date_field").returns( ["2009-12-31"] )

    @resource.stubs(:get_values_from_datastream).with("ng_ds", [{:person=>1}, :family_name]).returns( ["Samuelson"] )

    # @mock_md_ds.stubs(:first_name_values).returns( ["Bob"] )
    # @mock_md_ds.stubs(:last_name_values).returns( ["Bob","Bill"] )
    # @mock_md_ds.stubs(:abstract_values).returns( ["Textile1","Textile2"] )
    # @mock_md_ds.stubs(:drop_down_values).returns( ["Value1"] )
    # @mock_md_ds.stubs(:date_field_values).returns( ["2009-12-31"] )

  end
  
  describe "single_value_inline_edit" do
    describe "label" do
      it "should return a label when provided" do
        helper.single_value_inline_edit(@resource,"simple_ds","first_name",:label=>"First Name:")[:label].should == "First Name:"
      end
      it "should return the field name as the label if none is provided" do
        helper.single_value_inline_edit(@resource,"simple_ds","first_name")[:label].should == "first_name"
      end
    end
    
    describe "field" do
      it "should put the value in an editable span" do
        helper.single_value_inline_edit(@resource,"simple_ds","first_name")[:field].should match(/<span.*class=\"editableText\".*>Bob<\/span>/)
      end
      it "should wrap the editable span in an appropriate list element with the correct class and name" do
        helper.single_value_inline_edit(@resource,"simple_ds","first_name")[:field].should match(/<li class=\"editable\" name=\"asset\[simple_ds\]\[first_name\]\[0\]">.*<\/li>/)                                                                                                          
        # This was the test before we stuck a bunch of url params in the name attribute:
        # helper.single_value_inline_edit(@resource,"simple_ds","first_name")[:field].should match(/<li class=\"editable\" name=\"asset\[first_name\]\[0\]\">.*<\/li>/)
      end
      it "should work with nokogiri datastreams, inserting additional information into the input" do
        helper.single_value_inline_edit(@resource,"ng_ds",[{:person=>1}, :family_name])[:field].should match(/<li class=\"editable\" name=\"field_selectors%5Bng_ds%5D%5Bperson_1_family_name%5D%5B%5D%5Bperson%5D=1&field_selectors%5Bng_ds%5D%5Bperson_1_family_name%5D%5B%5D=family_name&asset\[ng_ds\]\[person_1_family_name\]\[0\]">.*<\/li>/)
      end
    end  
  end
  
  describe "multi_value_inline_edit" do
    describe "label" do
      it "should return a label when provided" do
        multi_line = helper.multi_value_inline_edit(@resource,"simple_ds","last_name",:label=>"Last Name:")[:label]
        multi_line.should match(/^Last Name:/) and
        multi_line.should match(/<a.*>\+<\/a>/)
      end
      it "should return the field name as the label if none is provided" do
        multi_line = helper.multi_value_inline_edit(@resource,"simple_ds","last_name")[:label]
        multi_line.should match("last_name") and
        multi_line.should match(/<a.*>\+<\/a>$/)
      end
    end
    
    describe "field" do
      it "should put the value in an editable spans" do
        multi_line = helper.multi_value_inline_edit(@resource,"simple_ds","last_name")[:field]
        multi_line.should match(/<span.*class=\"editableText\".*>Bob<\/span>/) and
        multi_line.should match(/<span.*class=\"editableText\".*>Bill<\/span>/)
      end
      it "should wrap the editable span in an appropriate list elements with the correct classes and names" do
        multi_line = helper.multi_value_inline_edit(@resource,"simple_ds","last_name")[:field]
        multi_line.should match(/<li class=\"editable\" name=\"asset\[simple_ds\]\[last_name\]\[0\]\">.*<\/li>/) and
        multi_line.should match(/<li class=\"editable\" name=\"asset\[simple_ds\]\[last_name\]\[1\]\">.*<\/li>/)
      end
    end  
  end
  
  describe "editable_textile" do
    describe "label" do
      it "should return a label when provided" do
        textile = helper.editable_textile(@resource,"simple_ds","abstract",:label=>"Abstract:")[:label]
        textile.should match(/^Abstract:/) 
      end
      it "should return the field name as the label if none is provided" do
        textile = helper.editable_textile(@resource,"simple_ds","abstract")[:label] 
        textile.should match(/^abstract/)
      end
      it "should support :multiple option" do
        textile = helper.editable_textile(@resource,"simple_ds","abstract",:multiple=>true)[:label] 
        textile.should match(/^abstract/) and
        textile.should match(/<a.*>\+<\/a>$/)
      end
    end
    
    describe "field" do
      it "have the correct li elements for each field" do
        textile = helper.editable_textile(@resource,"simple_ds","abstract")[:field]
        textile.should match(/<li name=\"asset\[simple_ds\]\[abstract\]\[0\]\".*>.*<\/li>/) and
        textile.should match(/<li name=\"asset\[simple_ds\]\[abstract\]\[1\]\".*>.*<\/li>/)
      end
      it "should have textile rendered HTML for each field" do
        textile = helper.editable_textile(@resource,"simple_ds","abstract")[:field]
        textile.should match(/<p>Textile1<\/p>/) and
        textile.should match(/<p>Textile2<\/p>/)
      end
    end  
  end

  describe "metadata_drop_down" do
    before(:all) do
      @choices = {:Value1=>"Value1",:Value2=>"Value2"}
    end
    
    describe "label" do
      it "should return a label when provided" do
        helper.metadata_drop_down(@resource,"simple_ds","drop_down",:label=>"Drop Down:",:choices=>@choices)[:label].should == "Drop Down:"
      end
      it "should return the field name as the label if none is provided" do
        helper.metadata_drop_down(@resource,"simple_ds","drop_down",:choices=>@choices)[:label].should == "drop_down"
      end
    end
    
    describe "field" do
      it "should have an option in the select element for each value provided" do
        drop_down = helper.metadata_drop_down(@resource,"simple_ds","drop_down",:choices=>@choices)[:field]
        drop_down.should match(/<option value=\"Value1\".*>Value1<\/option>/) and
        drop_down.should match(/<option value=\"Value2\">Value2<\/option>/)
      end
      it "should not include an additional element in the drop down from the choices if it is also the returned field value" do
        helper.metadata_drop_down(@resource,"simple_ds","drop_down",:choices=>@choices)[:field].should_not match(/<option value=\"Value1\">Value1<\/option>/)
      end
    end  
  end

  describe "date_select" do
    describe "label" do
      it "should return a label when provided" do
        helper.date_select(@resource,"simple_ds","date_field",:label=>"Date:")[:label].should == "Date:"
      end
      it "should return the field name as the label if none is provided" do
        helper.date_select(@resource,"simple_ds","date_field")[:label].should == "date_field"
      end
    end
    
    describe "field" do
      it "should have the provided month selected in the drop down" do
        # When the field is selected it will have the word selected in the option field
        helper.date_select(@resource,"simple_ds","date_field")[:field].should_not match(/<option value=\"12\">December<\/option>/)
      end
      it "should have the provided day selected in the drop down" do
        # When the field is selected it will have the word selected in the option field
        helper.date_select(@resource,"simple_ds","date_field")[:field].should_not match(/<option value=\"31\">31<\/option>/)
      end
      it "should have the select fields wrapped in an appropriate named div" do
        helper.date_select(@resource,"simple_ds","date_field")[:field].should match(/^<div class=\"date-select\" name=\"asset\[simple_ds\]\[date_field\]\[0\]\">/)
      end
    end
  end
  
  describe "get_values_from_datastream" do
    it "(with nokogiri datastreams) should call lookup with field_name and returns the text values from each resulting node" do
      @resource.expects(:get_values_from_datastream).with("ds1", "--my xpath--").returns(["value1", "value2"])
      helper.get_values_from_datastream(@resource, "ds1", "--my xpath--").should == ["value1", "value2"]
    end
  end


end