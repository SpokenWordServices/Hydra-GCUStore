require 'spec_helper'

describe ObjectDc do
  before do
    repository = mock('repo')
    @inner_obj = mock('inner obj', :repository => repository, :pid=>'__PID__' )
    repository.expects(:config)
  end
  it "should have a date node" do
    ObjectDc.new(@inner_obj, nil).to_xml.should match /<dc:date\/>/
  end

  it "should set the date value" do
    @ds = ObjectDc.new(@inner_obj, nil)
    @ds.update_values({[:dc_date] => ['2012-12']})
    @ds.to_xml.should match /<dc:date>2012-12<\/dc:date>/

  end
end
