# frozen_string_literal: true

Capybara.server_host = 'localhost'
Capybara.server_port = 3000
Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

require 'selenium/webdriver'

def common_chrome_options
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument '--window-size=1680,1050'
  options.add_argument '--disable-search-engine-choice-screen'
  options
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: common_chrome_options)
end

Capybara.register_driver :headless_chrome do |app|
  options = common_chrome_options
  options.add_argument '--headless=new'

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.javascript_driver = :headless_chrome

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by Capybara.javascript_driver
  end
end
