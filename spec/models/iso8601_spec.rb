require 'spec_helper'

describe Hull::Iso8601 do

  describe "with a single date" do
    it "should accept a string with format YYYY" do
      @iso = Hull::Iso8601.parse('2006')
      @iso.to_s.should == '2006'
    end
    it "should accept a string with format YYYY-MM" do
      @iso = Hull::Iso8601.parse('2006-09')
      @iso.to_s.should == '2006-09'
      @iso.month.should == '09'
    end
    it "should accept an invalid month with format YYYY-MM" do
      lambda {Hull::Iso8601.parse('2006-13')}.should raise_error ArgumentError
      lambda {Hull::Iso8601.parse('2006-00')}.should raise_error ArgumentError
    end
    it "should not accept a string without separators" do
      lambda {Hull::Iso8601.parse('200609')}.should raise_error ArgumentError
    end
    it "should accept a string with format YYYY-MM-DD" do
      @iso = Hull::Iso8601.parse('2006-08-30')
      @iso.to_s.should == '2006-08-30'
    end

    it "should accept leap days" do
      @iso = Hull::Iso8601.parse('2008-02-29')
      @iso.to_s.should == '2008-02-29'
    end

    it "should not accept leap days on years the don't occur" do
      lambda {Hull::Iso8601.parse('2009-02-29')}.should raise_error ArgumentError
    end
  end

  describe "with an range" do
    it "should accept a string with format YYYY/YYYY" do
      @iso = Hull::Iso8601.parse('2006/2009')
      @iso.to_s.should == '2006/2009'
    end
    it "should not accept a range where one date is invalid" do
      lambda {Hull::Iso8601.parse('2009/29')}.should raise_error ArgumentError
    end
    
  end


end
