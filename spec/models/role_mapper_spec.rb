require 'spec_helper'

describe RoleMapper do
 
 # overwritten for HULL with 6 roles
 it "should define the 4 roles" do
   RoleMapper.role_names.sort.should == %w(archivist contentAccessTeam donor patron researcher staff student) 
 end
 it "should quer[iy]able for roles for a given user" do
   RoleMapper.roles('leland_himself@example.com').sort.should == ['archivist', 'donor', 'patron']
   RoleMapper.roles('archivist2@example.com').should == ['archivist']
 end

 it "should return an empty array if there are no roles" do
   RoleMapper.roles('Marduk,_the sun_god@example.com').empty?.should == true
 end
 it "should know who is what" do
   RoleMapper.whois('archivist').sort.should == %w(archivist1@example.com archivist2@example.com leland_himself@example.com)
   RoleMapper.whois('stimutax salesman').empty?.should == true
 end

end
