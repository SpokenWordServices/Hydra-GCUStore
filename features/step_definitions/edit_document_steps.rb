require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^the "([^\"]*)" inline edit should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("dd ol li.editable") do |editable|
        editable.should have_selector("span", :content=>arg2, :class=>"editableText")
      end 
    end
  end
end

Then /^the "([^\"]*)" inline date edit should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("dd ol li.editable_date_picker") do |editable_date_picker|
        editable_date_picker.should have_selector(".editableText", :content=>arg2)
      end 
    end
  end
end

Then /^the "([^\"]*)" dropdown edit should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("select") do |dropdown|
        dropdown.should have_selector("option", :content=>arg2, :selected=>"selected")
      end
    end
  end
end

Then /^the "([^\"]*)" inline textarea edit should contain "([^\"]*)"$/ do |arg1, arg2|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("dd ol li.editable_textarea") do |editable_textarea|
        editable_textarea.should have_selector(".flc-inlineEdit-text", :content=>arg2)
      end
    end
  end
end

Then /^the "([^\"]*)" inline textarea edit should be empty$/ do |arg1|
  response.should have_selector("dt", :content=>arg1) do |dt|
    dt.each do |term| 
      term.next.should have_selector("dd ol li.editable_textarea") do |editable_textarea|
        editable_textarea.should have_selector(".flc-inlineEdit-text", :content=>nil)
      end
    end
  end
end

