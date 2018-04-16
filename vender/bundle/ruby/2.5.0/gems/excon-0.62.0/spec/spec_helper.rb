require 'excon'
require 'excon/test/server'
require 'json'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

 config.mock_with :rspec do |mocks|
   mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
end

# Load helpers
Dir["./spec/helpers/**/*.rb"].sort.each { |f| require f}

# Load shared examples and contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f}
