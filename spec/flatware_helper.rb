# frozen_string_literal: true

Flatware.configure do |config|
  config.after_fork do |test_env_number|
    unless ENV.fetch('DISABLE_SIMPLECOV', nil) == 'true'
      SimpleCov.at_fork.call(test_env_number) # Combines parallel coverage results
    end
  end
end
