# encoding: utf-8

require 'equatable'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.raise_errors_for_deprecations!
end
