# coding: utf-8

module Stoplight # rubocop:disable Style/Documentation
end

require 'stoplight/version'

require 'stoplight/color'
require 'stoplight/error'
require 'stoplight/failure'
require 'stoplight/state'

require 'stoplight/data_store'
require 'stoplight/data_store/base'
require 'stoplight/data_store/memory'
require 'stoplight/data_store/redis'

require 'stoplight/notifier'
require 'stoplight/notifier/base'
require 'stoplight/notifier/generic'

require 'stoplight/notifier/bugsnag'
require 'stoplight/notifier/hip_chat'
require 'stoplight/notifier/honeybadger'
require 'stoplight/notifier/io'
require 'stoplight/notifier/logger'
require 'stoplight/notifier/raven'
require 'stoplight/notifier/slack'

require 'stoplight/default'

require 'stoplight/light/runnable'
require 'stoplight/light'

# @see Stoplight::Light#initialize
def Stoplight(name, &code) # rubocop:disable Style/MethodName
  Stoplight::Light.new(name, &code)
end
