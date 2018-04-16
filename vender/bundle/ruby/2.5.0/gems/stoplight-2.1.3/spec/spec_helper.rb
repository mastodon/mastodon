# coding: utf-8

require 'coveralls'
Coveralls.wear!

require 'stoplight'
require 'timecop'

Timecop.safe_mode = true

RSpec.configure do |rspec|
  rspec.color = true
  rspec.disable_monkey_patching!
  rspec.order = :random
  rspec.warnings = true
end
