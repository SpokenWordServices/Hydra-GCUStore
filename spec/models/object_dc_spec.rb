require 'spec_helper'

describe ObjectDc do
  it "should have a date node" do
    ObjectDc.new.to_xml.should match /<dc:date\/>/
  end

  it "should set the date value" do
    @ds = ObjectDc.new
    @ds.update_values({[:dc_dateIssued] => ['2012-12']})
    @ds.to_xml.should match /<dc:date>2012-12<\/dc:date>/

  end
end
