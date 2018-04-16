require "logger"
require_relative "core"
require_relative "logging-observer"

module Rack::Timeout::Logger
  extend self
  attr :device, :level, :logger

  def device=(new_device)
    update(new_device, level)
  end

  def level=(new_level)
    update(device, new_level)
  end

  def logger=(new_logger)
    @logger = @observer.logger = new_logger
  end

  def init
    @observer = ::Rack::Timeout::StateChangeLoggingObserver.new
    ::Rack::Timeout.register_state_change_observer(:logger, &@observer.callback)
    @inited = true
  end

  def disable
    @observer, @logger, @level, @device, @inited = nil
    ::Rack::Timeout.unregister_state_change_observer(:logger)
  end

  def update(new_device, new_level)
    init unless @inited
    @device     = new_device || $stderr
    @level      = new_level  || ::Logger::INFO
    self.logger = ::Rack::Timeout::StateChangeLoggingObserver.mk_logger(device, level)
  end

end
