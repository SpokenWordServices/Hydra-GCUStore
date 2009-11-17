require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^the "([^\"]*)" inline edit should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("dd") do |dd|
        dd.should have_selector("span", :content=>arg2, :class=>"editableText")
      end 
    end
  end
end