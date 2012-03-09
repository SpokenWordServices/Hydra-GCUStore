class CreatePeople < ActiveRecord::Migration
  def self.up
      create_table :people do |t|
       t.string :user_name
       t.string :forename
       t.string :surname
       t.string :emailAddress
       t.string :userType
       t.string :departmentOU
       t.string :subDepartmentCode
      end
  end

  def self.down
      drop_table :people
  end
end
