require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HydraRenderingHelper do
  include HydraRenderingHelper
  describe "get_person_from_role" do
    before(:all) do
      @single_person_doc = {"person_0_role_t" => ["creator"], "person_0_first_name_t" => "GIVEN NAME", "person_0_last_name_t" => "FAMILY NAME"}
      @multiple_persons_doc = {"person_0_role_t" => ["contributor","owner"], "person_0_first_name_t" => "CONTRIBUTOR GIVEN NAME", "person_0_last_name_t" => "CONTRIBUTOR FAMILY NAME",
                               "person_1_role_t" => ["creator"], "person_1_first_name_t" => "CREATOR GIVEN NAME", "person_1_last_name_t" => "CREATOR FAMILY NAME"}
     end
     it "should return the appropriate  when 1 is available" do
       person = get_person_from_role(@single_person_doc,"creator")
       person[:first].should == "GIVEN NAME" and
       person[:last].should == "FAMILY NAME"
     end
     it "should return the appririate person when there is multiple users" do
       person = get_person_from_role(@multiple_persons_doc,"creator")
       person[:first].should == "CREATOR GIVEN NAME" and
       person[:last].should == "CREATOR FAMILY NAME"
     end
     it "should return the appropriate person when they have multiple roles" do
       person = get_person_from_role(@multiple_persons_doc,"owner")
       person[:first].should == "CONTRIBUTOR GIVEN NAME" and 
       person[:last].should == "CONTRIBUTOR FAMILY NAME"
     end
     it "should return nil when there is no user for the given role" do
       get_person_from_role(@multiple_persons_doc,"bad_role").should be_nil
     end
  end
end

