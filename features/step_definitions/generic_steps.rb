Then /^I should get valid JSON$/ do
  last_response.should be_ok
  lambda { JSON.parse last_response.body }.should_not raise_error
end
