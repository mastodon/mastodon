# frozen_string_literal: true

if ENV['CI']
  require 'simplecov-lcov'
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.start 'rails' do
  enable_coverage :branch

  add_filter 'lib/linter'

  add_group 'Libraries', 'lib'
  add_group 'Policies', 'app/policies'
  add_group 'Presenters', 'app/presenters'
  add_group 'Serializers', 'app/serializers'
  add_group 'Services', 'app/services'
  add_group 'Validators', 'app/validators'
end
