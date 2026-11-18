# frozen_string_literal: true

# TODO: https://github.com/briandunn/flatware/pull/123
# Monitor for updated instructions / automation
if defined?(Flatware)
  Flatware.configure do |config|
    config.before_fork do
      parent_pid = Process.pid
      at_exit do
        next if Process.pid != parent_pid

        begin
          Process.waitall
        rescue Errno::ECHILD
          # No remaining children — already reaped elsewhere.
        end
      end
    end
  end
end

SimpleCov.configure do
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
