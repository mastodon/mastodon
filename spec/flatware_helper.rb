# frozen_string_literal: true

if defined?(Flatware)
  Flatware.configure do |config|
    config.after_fork do |test_env_number|
      unless ENV.fetch('DISABLE_SIMPLECOV', nil) == 'true'
        require 'simplecov'
        SimpleCov.at_fork.call(test_env_number) # Combines parallel coverage results
      end
    end
  end
end
