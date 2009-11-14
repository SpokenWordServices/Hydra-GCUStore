require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^the "([^\"]*)" term should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt")
end

Given /^I am logged in as "([^\"]*)"$/ do |arg1|
  pending
end

Then /^I should see the "([^\"]*)" value$/ do |arg1|
  pending
end

Then /^I should see a link to the "([^\"]*)"$/ do |arg1|
  pending
end

Then /^I should see a link to the "([^\"]*)" page$/ do |arg1|
  pending
end

Then /^related links are displayed as urls$/ do
  pending
end
