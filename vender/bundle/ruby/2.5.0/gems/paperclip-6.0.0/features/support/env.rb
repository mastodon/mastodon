require 'aruba/cucumber'
require 'capybara/cucumber'
require 'rspec/matchers'

$CUCUMBER=1

World(RSpec::Matchers)

Before do
  aruba.config.command_launcher = ENV.fetch("DEBUG", nil) ? :debug : :spawn
  @aruba_timeout_seconds = 120
end
