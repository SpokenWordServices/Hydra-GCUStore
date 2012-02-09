require 'spec_helper'
require 'user_helper'

describe RoleMapper do
  include UserHelper
 
 # overwritten for HULL with 6 roles
 it "should define the 4 roles" do
   #load_roles
   RoleMapper.role_names.sort.should == %w(contentAccessTeam guest student) 
 end
 it "should quer[iy]able for roles for a given user" do
   #@user = User.create!(:username => "contentAccessTeam1", :email => "contentAccessTeam1@example.com")
   #@user.roles = [Role.find_or_initialize_by_name("contentAccessTeam")]
   RoleMapper.roles('contentAccessTeam1').should == ['contentAccessTeam']
 end

 it "should return an empty array if there are no roles" do
   RoleMapper.roles('Marduk,_the sun_god@example.com').empty?.should == true
 end
 it "should know who is what" do
   RoleMapper.whois('contentAccessTeam').sort.should == %w(contentAccessTeam1)
   RoleMapper.whois('stimutax salesman').empty?.should == true
 end

end
