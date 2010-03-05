require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I should see (\d+) (gallery|list) results$/ do |number,type|
  if type == "gallery"
    results_num = response.body.scan(/<div class=\"document thumbnail\">/).length
  elsif type == "list"
    results_num = response.body.scan(/<tr class=\"document (odd|even)\">/).length
  else
    results_num = -1
  end
  results_num.should == number.to_i
end