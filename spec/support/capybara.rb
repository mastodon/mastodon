# frozen_string_literal: true

Capybara.server_host = 'localhost'
Capybara.server_port = 3000
Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app)
end
Capybara.javascript_driver = :playwright

if ENV['CI'].present?
  # Reduce intermittent failures from slow CI runner environment
  Capybara.default_max_wait_time = 2**3
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by Capybara.javascript_driver
  end
end
