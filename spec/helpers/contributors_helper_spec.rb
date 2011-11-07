require 'spec_helper'

describe ContributorsHelper do
  
  describe "editable?" do
    it "should return whether or not a given content type is editable" do
      pending("Test coverage not implemented yet for this")
    end
  end

  describe "param extractions" do
    before :each do
      @good_hash = {"person_99_namePart"=>{"0"=>"FOO"},"person_99_role_text"=>{"0"=>"BAR"}}
      @bad_hash = {"person_99_name_part"=>{"0"=>"FOO"},"person_99_roleText"=>{"0"=>"BAR"}}
    end

    describe "extract_name_value" do
      
      it "should return the nested name from indexed hash" do
        helper.extract_name_value(@good_hash).should == "FOO"
      end

      it "should return nil if no value is found" do
        helper.extract_name_value(@bad_hash).should be_nil
      end
    end

    describe "extract_role_value" do 
      it "should return the nested name from indexed hash" do
        helper.extract_role_value(@good_hash).should == "BAR"
      end

      it "should return nil if no value is found" do
        helper.extract_role_value(@bad_hash).should be_nil
      end
    end
  end
end
