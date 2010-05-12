Given /^I am logged in as "([^\"]*)"$/ do |login|
  email = "#{login}@#{login}.com"
  user = User.create(:login => login, :email => email, :password => "password", :password_confirmation => "password")
  visit user_sessions_path(:user_session => {:login => login, :password => "password"}), :post
  User.find(user.id).should_not be_nil
end