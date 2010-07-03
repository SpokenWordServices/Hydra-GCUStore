# really ugly way of mocking out our user and roles for a simple test
def current_user
  def login
    "login_name"
  end
  "User"
end
class RoleMapper
  def self.roles *args
    ["archivist","researcher"]
  end
end
require File.expand_path( File.join( File.dirname(__FILE__), '..','..','spec_helper') )
describe Hydra::AccessControlsEnforcement do
 include Hydra::AccessControlsEnforcement
 describe "build_lucene_query" do
   it "should return fields for all roles the user is a member of checking against the discover, access, read fields" do
     query = build_lucene_query("string")
     ["discover","edit","read"].each do |type|
       query.should match(/_query_\:\"#{type}_access_group_t\:archivist/) and
       query.should match(/_query_\:\"#{type}_access_group_t\:researcher/)
     end
   end
   it "should return fields for all the person specific discover, access, read fields" do
     query = build_lucene_query("string")
     ["discover","edit","read"].each do |type|
       query.should match(/_query_\:\"#{type}_access_person_t\:#{current_user.login}/)
     end
   end
   
 end
end


