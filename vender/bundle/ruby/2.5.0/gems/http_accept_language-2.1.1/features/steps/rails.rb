Before "@rails" do
  @rails = RailsDriver.new
end

When /^I generate a new Rails app$/ do
  @rails.generate_rails
end

When /^I add http_accept_language to my Gemfile$/ do
  @rails.append_gemfile
end

Given /^I have installed http_accept_language$/ do
  @rails.install_gem
end

When /^I generate the following controller:$/ do |string|
  @rails.generate_controller "languages", string
end

When /^I access that action with the HTTP_ACCEPT_LANGUAGE header "(.*?)"$/ do |header|
  @rails.with_rails_running do
    @rails.request_with_http_accept_language_header(header, "/languages")
  end
end

Then /^the response should contain "(.*?)"$/ do |output|
  @rails.output_should_contain(output)
end

When /^I run `rake middleware`$/ do
  @rails.bundle_exec("rake middleware")
end

Then /^the output should contain "(.*?)"$/ do |expected|
  @rails.assert_partial_output(expected, @rails.all_output)
end
