Given /^I am logged in as "([^\"]*)"$/ do |email|

  #Derive username from email - means we can leave tests 'as is'
  username = email[0..email.index('@')-1].to_s

	

  #Insert the all the possible test users into DB 
  #now done through fixture
#  ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('contentAccessTeam1', 'content', 'team', 'contentAccessTeam1@example.com', 'staff', 'Dep', 'SubDep')")
#  ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('staff1', 'staff', 'user', 'staff1@example.com', 'staff', 'Dep', 'SubDep')")
#  ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('student1', 'student', 'user', 'student1@example.com', 'student', 'Dep', 'SubDep')")
#  ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('archivist1', 'archivist', 'user', 'archivist1@example.com', 'archivist', 'Dep', 'SubDep')")
#ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('bigwig', 'bigwig', 'user', 'bigwig@example.com', 'staff', 'Dep', 'SubDep')")

  #Insert all the roles into DB
#  ActiveRecord::Base.connection.execute("INSERT INTO roles (name, description) VALUES ('contentAccessTeam', 'contentAccessTeam')")
#  ActiveRecord::Base.connection.execute("INSERT INTO roles (name, description) VALUES ('staff', 'staff')")
#  ActiveRecord::Base.connection.execute("INSERT INTO roles (name, description) VALUES ('student', 'student')")
#  ActiveRecord::Base.connection.execute("INSERT INTO roles (name, description) VALUES ('archivist', 'archivist')")
#  ActiveRecord::Base.connection.execute("INSERT INTO roles (name, description) VALUES ('guest', 'guest')")
#  ActiveRecord::Base.connection.execute("INSERT INTO roles (name, description) VALUES ('researcher', 'researcher')")

  #Get the relevant reference to the role...
  if username.include? "staff"
    role = Role.find_or_initialize_by_name("staff")
  elsif username.include? "student"
    role = Role.find_or_initialize_by_name("student")
  elsif username.include? "contentAccessTeam"
   role = Role.find_or_initialize_by_name("contentAccessTeam")
  elsif username.include? "archivist"
   role = Role.find_or_initialize_by_name("archivist")
  else
   role = Role.find_or_initialize_by_name("guest")
  end

  #Create the user
#  @current_user = User.create!(:username => username, :email => email)
  @current_user = User.create!(:email => email, :password => "password", :password_confirmation => "password", :username => username)

  #Add the role
  @current_user.roles = [role]
  User.find_by_username(username).should_not be_nil

  #Uses the warden helper method to log a user in without needed to use a CAS login... 
  #login_as @current_user, :scope => :user

  visit '/users/sign_in'
  fill_in "user_email", :with=>email
  fill_in "user_password", :with=>"password"
  fill_in "user_username", :with =>username
  click_button "Sign in"

  visit resources_path

 #visit destroy_user_session_path
 #visit new_user_session_path
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
