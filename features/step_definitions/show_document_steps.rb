require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

# Terms (dt / dd pairs)

Then /^I should see the "([^\"]*)" term$/ do |arg1|
  response.should have_selector("dt", :content=>arg1) 
end

Then /^I should not see the "([^\"]*)" term$/ do |arg1|
  response.should_not have_selector("dt", :content=>arg1) 
end

Then /^the "([^\"]*)" term should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("dd", :content=>arg2) 
    end
  end
end

Then /^I should see the "([^\"]*)" value$/ do |arg1|
  pending
end

Then /^I should see a link to "([^\"]*)"$/ do |arg1|
  response.should have_selector("a", :href=>path_to(arg1))
end

Then /^I should see a link to the "([^\"]*)" page$/ do |arg1|
  response.should have_selector("a", :href=>path_to(arg1))
end

Then /^I should not see a link to "([^\"]*)"$/ do |arg1|
  response.should_not have_selector("a", :href=>path_to(arg1))
  puts path_to(arg1)
end

Then /^I should not see a link to the "([^\"]*)" page$/ do |arg1|
  response.should_not have_selector("a", :href=>path_to(arg1))
  puts path_to(arg1)
end

Then /^related links are displayed as urls$/ do
  pending
end
