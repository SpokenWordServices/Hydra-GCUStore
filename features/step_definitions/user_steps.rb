Given /^I am logged in as "([^\"]*)"$/ do |email|
  user = User.create(:email => email, :password => "password", :password_confirmation => "password")
  User.find_by_email(email).should_not be_nil
  visit destroy_user_session_path
  visit new_user_session_path
  fill_in "Email", :with => email 
  fill_in "Password", :with => "password"
  click_button "Sign in"
  And %{I should see a link to "logout"} 
end

Given /^I am a superuser$/ do
  Given %{I am logged in as "bigwig@example.com"}
  bigwig_id = User.find_by_email("bigwig@example.com").id
  superuser = Superuser.create(:id => 20, :user_id => bigwig_id)
  visit superuser_path
end
