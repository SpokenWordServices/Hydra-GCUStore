# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Seed Data for the Roles table

#Role data
#Clear existing data
Role.delete_all
#Re-seed the data
["contentAccessTeam", "staff", "student", "committeeSection", "engineering", "guest"].each {|r| Role.create(:name => r, :description => r) } 
#Add some people so we are recognised and can get admin rights
Person.find_or_create_by_user_name('staff1', :userType => 'staff', :emailAddress => 'staff1@example.com')
Person.find_or_create_by_user_name('student1', :userType => 'student', :emailAddress => 'student1@example.com')
Person.find_or_create_by_user_name('cat1', :userType => 'contentAccessTeam', :emailAddress => 'contentaccessteam1@example.com')
Person.find_or_create_by_user_name('cs1', :userType => 'committeeSection', :emailAddress => 'committeesection1@example.com')

# Seed the Licence data
Licence.find_or_create_by_name ('Spoken Word End-User Licence', :link => 'http://catalogue.spokenword.ac.uk/spoken-word-end-user-licence-agreement.html', :description => 'This resource is downloadable under the Spoken Word End-User Licence. Please read and understand the licence before downloading.', :download => true)
Licence.find_or_create_by_name ('Creative Commons Attribution-NonCommercial-ShareAlike 2.5', :link => 'http://creativecommons.org/licences/by-nc-sa/2.5/', :description => '', :download => true)

