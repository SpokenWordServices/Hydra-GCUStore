include Devise::TestHelpers

Given /^I am logged in as "([^\"]*)"$/ do |email|
  user = User.create(:email => email, :password => "password", :password_confirmation => "password")
  User.find_by_email(email).should_not be_nil
	
  #Derive username from email - means we can leave tests 'as is'
  #username = email[0..email.index('@')-1].to_s

	#ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('contentAccessTeam1', 'content', 'team', 'contentAccessTeam1@example.com', 'staff', 'Dep', 'SubDep')")

  #role = Role.find_or_initialize_by_name("contentAccessTeam")
  #user = User.create!(:username => username, :email => username + "@example.com", :roles => role.to_a)
	User.find_by_email(email).should_not be_nil

	#debugger
  #sign_in user          # sign_in(resource)


  visit destroy_user_session_path
 # visit new_user_session_path
 # fill_in "Email", :with => email 
 # fill_in "Password", :with => "password"
 # click_button "Sign in"
  step %{I should see a link to "logout"} 
end

Given /^I am a superuser$/ do
  step %{I am logged in as "bigwig@example.com"}
  bigwig_id = User.find_by_email("bigwig@example.com").id
  superuser = Superuser.create(:id => 20, :user_id => bigwig_id)
  visit superuser_path
end
