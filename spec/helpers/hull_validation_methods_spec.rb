require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

class TestValidationClassOne
  include HullValidationMethods

  has_workflow_validation :qa do
    is_valid?
  end

  has_workflow_validation :other do
    errors << "big bad error"
    is_valid?
  end
end

describe HullValidationMethods do
  before :each do 
    @tvc = TestValidationClassOne.new
  end 

  describe "has_workflow_validation" do
    it "should provide ? methods for validation" do
      @tvc.respond_to?(:ready_for_qa?).should be_true
      @tvc.respond_to?(:ready_for_other?).should be_true
    end
    it "should return false if validations failed" do
      @tvc.ready_for_other?.should be_false
      @tvc.errors.length.should == 1
    end
    it "should return true if no validations failed" do
      @tvc.ready_for_qa?.should be_true
      @tvc.errors.should be_empty
    end
  end

  describe ".validation" do
    it "should accept a block for validating attributes" do
      @tvc.class_eval <<-EOF
        def is_ready_for_action?
          validation { 3.times {puts "whoo hoo"} }
        end
      EOF
      @tvc.is_ready_for_action?.should be_true 
    end
    it "should raise an error if no block is given" do
      lambda { @tvc.send(:validation) }.should raise_error HullValidationMethods::NoValidationBlockGiven
    end
    it "should return false if the block adds to errors" do
      @tvc.class_eval <<-EOF
       def ready?
         validation do
           errors << "this is an error"
         end
       end
      EOF
      @tvc.ready?.should be_false
      @tvc.errors.should == ["this is an error"]
    end
  end
  describe ".validates_presence_of" do
    before :each do
      mock_ds = mock("ds")
      mock_ds.stubs(:get_values).with([:foo,:bar]).returns(["baz"])
      mock_ds.stubs(:get_values).with([:no,:potatoes]).returns([])
      @tvc.stubs(:datastreams).returns({"descMetadata"=>mock_ds})
    end
    
    it "should return true and have no errors listed if the given field has a value within the given datastream" do
      @tvc.send(:validates_presence_of,"descMetadata",[:foo,:bar]).should be_true
      @tvc.errors.should be_a_kind_of Array
      @tvc.errors.empty?.should be_true
    end
    describe "on failure" do
      it "should return false and populate .errors w/ standard message" do
        @tvc.send(:validates_presence_of,"descMetadata",[:no,:potatoes]).should be_false
        @tvc.errors.should be_a_kind_of Array
        @tvc.errors.length.should == 1
        @tvc.errors.should == ["descMetadata[no_potatoes] is missing"]
      end
      it "should return false and populate .errors with custom message when :message option is passed" do
        @tvc.send(:validates_presence_of,"descMetadata",[:no,:potatoes],:message=>"must have data").should be_false
        @tvc.errors.should be_a_kind_of Array
        @tvc.errors.length.should == 1
        @tvc.errors.should == ["descMetadata[no_potatoes] must have data"]
      end
    end
  end
  describe ".validates_format_of" do
    before :each do
      mock_ds = mock("ds")
      mock_ds.stubs(:get_values).with([:foo,:bar]).returns(["baz123"])
      mock_ds.stubs(:get_values).with([:potatoes,:year_expired]).returns(["2011"])
      @tvc.stubs(:datastreams).returns({"descMetadata"=>mock_ds})
    end
    
    it "should return true and have no errors listed if the given field has a value within the given datastream" do
      @tvc.send(:validates_format_of,"descMetadata",[:foo,:bar],:with=>/^\w{3}\d{3}$/).should be_true
      @tvc.errors.should be_a_kind_of Array
      @tvc.errors.empty?.should be_true
    end
    it "should raise error if no regexp is passed" do
      lambda { @tvc.send(:validates_format_of,"descMetadata").should raise_error ArgumentError }.should be_true
    end
    describe "on failure" do
      it "should return false and populate .errors w/ standard message" do
        @tvc.send(:validates_format_of,"descMetadata",[:foo,:bar], :with=>/^barfoo$/).should be_false
        @tvc.errors.should be_a_kind_of Array
        @tvc.errors.length.should == 1
        @tvc.errors.should == ["descMetadata[foo_bar] has invalid format"]
      end
      it "should return false and eopulate .errors with custom message when :message option is passed" do
        @tvc.send(:validates_format_of,"descMetadata",[:potatoes,:year_expired],:with=>/^\d{4}-\d{2}-\d{2}$/, :message=>"is completely hosed").should be_false
        @tvc.errors.should be_a_kind_of Array
        @tvc.errors.length.should == 1
        @tvc.errors.should == ["descMetadata[potatoes_year_expired] is completely hosed"]
      end
    end
  end

end
