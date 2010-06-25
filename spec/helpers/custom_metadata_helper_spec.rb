require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def first_name_values
  ["Bob"]
end

def last_name_values
  ["Bob","Bill"]
end
def abstract_values
  ["Textile1","Textile2"]
end
def drop_down_values
  ["Value1"]
end

def date_field_values
  ["2009-12-31"]
end

describe CustomMetadataHelper do
  include CustomMetadataHelper
  include MetadataHelper
  before(:all) do
    datastreams = {"datastream1"=>stub(:stream_values=>"value")}
    @resource = mock()
    @resource.stubs(:datastreams).returns(datastreams)
  end
  describe "custom_single_value_inline_edit" do
    describe "label" do
      it "should return a label when provided" do
        custom_single_value_inline_edit(@resource,"datastream1","first_name",:label=>"First Name:")[:label].should == "First Name:"
      end
      it "should return the field name as the label if none is provided" do
        custom_single_value_inline_edit(@resource,"datastream1","first_name")[:label].should == "first_name"
      end
    end
    
    describe "field" do
      it "should put the value in an editable span" do
        custom_single_value_inline_edit(@resource,"datastream1","first_name")[:field].should match(/<span.*class=\"editableText\".*>Bob<\/span>/)
      end
      it "should wrap the editable span in an appropriate list element with the correct class and name" do
        custom_single_value_inline_edit(@resource,"datastream1","first_name")[:field].should match(/<li class=\"editable\" name=\"datastream\=datastream1\&field_name=first_name\&asset\[first_name\]\[0\]">.*<\/li>/)
        # This was the test before we stuck a bunch of url params in the name attribute:
        # helper.single_value_inline_edit(@resource,"datastream1","first_name")[:field].should match(/<li class=\"editable\" name=\"asset\[first_name\]\[0\]\">.*<\/li>/)
      end
    end  
  end
  
  describe "custom_multi_value_inline_edit" do
    describe "label" do
      it "should return a label when provided" do
        multi_line = custom_multi_value_inline_edit(@resource,"datastream1","last_name",:label=>"Last Name:")[:label]
        multi_line.should match(/^Last Name:/) and
        multi_line.should match(/<a.*>\+<\/a>/)
      end
      it "should return the field name as the label if none is provided" do
        multi_line = custom_multi_value_inline_edit(@resource,"datastream1","last_name")[:label]
        multi_line.should match("last_name") and
        multi_line.should match(/<a.*>\+<\/a>$/)
      end
    end
    
    describe "field" do
      it "should put the value in an editable spans" do
        multi_line = custom_multi_value_inline_edit(@resource,"datastream1","last_name")[:field]
        multi_line.should match(/<span.*class=\"editableText\".*>Bob<\/span>/) and
        multi_line.should match(/<span.*class=\"editableText\".*>Bill<\/span>/)
      end
      it "should wrap the editable span in an appropriate list elements with the correct classes and names" do
        multi_line = custom_multi_value_inline_edit(@resource,"datastream1","last_name")[:field]
        multi_line.should match(/<li class=\"editable\" name=\"asset\[last_name\]\[0\]\">.*<\/li>/) and
        multi_line.should match(/<li class=\"editable\" name=\"asset\[last_name\]\[1\]\">.*<\/li>/)
      end
    end  
  end
  
  describe "custom_editable_textile" do
    describe "label" do
      it "should return a label when provided" do
        textile = custom_editable_textile(@resource,"datastream1","abstract",:label=>"Abstract:")[:label]
        textile.should match(/^Abstract:/) and
        textile.should match(/<a.*>\+<\/a>$/)
      end
      it "should return the field name as the label if none is provided" do
        textile = custom_editable_textile(@resource,"datastream1","abstract")[:label] 
        textile.should match(/^abstract/) and
        textile.should match(/<a.*>\+<\/a>$/)
      end
    end
    
    describe "field" do
      it "have the correct li elements for each field" do
        textile = custom_editable_textile(@resource,"datastream1","abstract")[:field]
        textile.should match(/<li name=\"asset\[abstract\]\[0\]\".*>.*<\/li>/) and
        textile.should match(/<li name=\"asset\[abstract\]\[1\]\".*>.*<\/li>/)
      end
      it "should have textile rendered HTML for each field" do
        textile = custom_editable_textile(@resource,"datastream1","abstract")[:field]
        textile.should match(/<p>Textile1<\/p>/) and
        textile.should match(/<p>Textile2<\/p>/)
      end
    end  
  end

  describe "custom_metadata_drop_down" do
    before(:all) do
      @choices = {:Value1=>"Value1",:Value2=>"Value2"}
    end
    
    describe "label" do
      it "should return a label when provided" do
        custom_metadata_drop_down(@resource,"datastream1","drop_down",:label=>"Drop Down:",:choices=>@choices)[:label].should == "Drop Down:"
      end
      it "should return the field name as the label if none is provided" do
        custom_metadata_drop_down(@resource,"datastream1","drop_down",:choices=>@choices)[:label].should == "drop_down"
      end
    end
    
    describe "field" do
      it "should have an option in the select element for each value provided" do
        drop_down = custom_metadata_drop_down(@resource,"datastream1","drop_down",:choices=>@choices)[:field]
        drop_down.should match(/<option value=\"Value1\".*>Value1<\/option>/) and
        drop_down.should match(/<option value=\"Value2\">Value2<\/option>/)
      end
      it "should not include an additional element in the drop down from the choices if it is also the returned field value" do
        custom_metadata_drop_down(@resource,"datastream1","drop_down",:choices=>@choices)[:field].should_not match(/<option value=\"Value1\">Value1<\/option>/)
      end
    end  
  end

  describe "custom_date_select" do
    describe "label" do
      it "should return a label when provided" do
        custom_date_select(@resource,"datastream1","date_field",:label=>"Date:")[:label].should == "Date:"
      end
      it "should return the field name as the label if none is provided" do
        custom_date_select(@resource,"datastream1","date_field")[:label].should == "date_field"
      end
    end
    
    describe "field" do
      it "should have the provided month selected in the drop down" do
        # When the field is selected it will have the word selected in the option field
        custom_date_select(@resource,"datastream1","date_field")[:field].should_not match(/<option value=\"12\">December<\/option>/)
      end
      it "should have the provided day selected in the drop down" do
        # When the field is selected it will have the word selected in the option field
        custom_date_select(@resource,"datastream1","date_field")[:field].should_not match(/<option value=\"31\">31<\/option>/)
      end
      it "should have the select fields wrapped in an appropriate named div" do
        custom_date_select(@resource,"datastream1","date_field")[:field].should match(/^<div class=\"date-select\" name=\"asset\[date_field\]\[0\]\">/)
      end
    end
  end


end