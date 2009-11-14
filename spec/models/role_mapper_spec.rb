require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleMapper do
  
 it "should define the 4 roles" do
   RoleMapper.role_names.sort.should == %w(archivist donor patron researcher) 
 end
 it "should quer[iy]able for roles for a given user" do
   RoleMapper.roles('alice').sort.should == ['archivist', 'donor', 'researcher']
   RoleMapper.roles('bob').should == ['archivist']
 end

 it "should return an empty array if there are no roles" do
   RoleMapper.roles('Marduk, the sun god').empty?.should == true
 end
 it "should know who is what" do
   RoleMapper.whois('archivist').sort.should == %w(alice bob charlie)
   RoleMapper.whois('stimutax salesman').empty?.should == true
 end

end
