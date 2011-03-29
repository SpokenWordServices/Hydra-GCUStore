require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleMapper do
 
 # overwritten for HULL with 6 roles
 it "should define the 4 roles" do
   RoleMapper.role_names.sort.should == %w(archivist contentAccessTeam donor patron researcher staff student) 
 end
 it "should quer[iy]able for roles for a given user" do
   RoleMapper.roles('leland_himself').sort.should == ['archivist', 'donor', 'patron']
   RoleMapper.roles('archivist2').should == ['archivist']
 end

 it "should return an empty array if there are no roles" do
   RoleMapper.roles('Marduk, the sun god').empty?.should == true
 end
 it "should know who is what" do
   RoleMapper.whois('archivist').sort.should == %w(archivist1 archivist2 leland_himself)
   RoleMapper.whois('stimutax salesman').empty?.should == true
 end

end
