# frozen_string_literal: true

SimpleCov.configure do
  # During parallel runs, ensure unique names for post-run merge
  command_name "job-#{ENV['TEST_ENV_NUMBER']}" if ENV['TEST_ENV_NUMBER']

  if ENV['CI']
    require 'simplecov-lcov'
    formatter SimpleCov::Formatter::LcovFormatter
    formatter.config.report_with_single_file = true
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end

  enable_coverage :branch, :eval

  skip 'lib/linter'

  group 'Libraries', 'lib'
  group 'Policies', 'app/policies'
  group 'Presenters', 'app/presenters'
  group 'Search', 'app/chewy'
  group 'Serializers', 'app/serializers'
  group 'Services', 'app/services'
  group 'Validators', 'app/validators'
  group 'Views', 'app/views'
end
