# frozen_string_literal: true

SimpleCov.start 'rails' do
  command_name "examples#{ENV.fetch('TEST_ENV_NUMBER', nil)}"

  if ENV['CI']
    require 'simplecov-lcov'
    SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
    formatter SimpleCov::Formatter::LcovFormatter
    # formatter SimpleCov::Formatter::SimpleFormatter
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end

  enable_coverage :branch

  add_filter 'lib/linter'

  add_group 'Libraries', 'lib'
  add_group 'Policies', 'app/policies'
  add_group 'Presenters', 'app/presenters'
  add_group 'Serializers', 'app/serializers'
  add_group 'Services', 'app/services'
  add_group 'Validators', 'app/validators'
end
