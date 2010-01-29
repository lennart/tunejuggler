Then /^I should get valid JSON$/ do
  puts "Response #{last_response.status}"
  [200,201].should include(last_response.status)
  lambda { JSON.parse last_response.body }.should_not raise_error
end
