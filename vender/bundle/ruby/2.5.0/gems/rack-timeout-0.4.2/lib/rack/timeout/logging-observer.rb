require "logger"
require_relative "core"

class Rack::Timeout::StateChangeLoggingObserver
  STATE_LOG_LEVEL = { :expired   => :error,
                      :ready     => :info,
                      :active    => :debug,
                      :timed_out => :error,
                      :completed => :info,
                    }

  # returns the Proc to be used as the observer callback block
  def callback
    method(:log_state_change)
  end

  SIMPLE_FORMATTER = ->(severity, timestamp, progname, msg) { "#{msg} at=#{severity.downcase}\n" }
  def self.mk_logger(device, level = ::Logger::INFO)
    ::Logger.new(device).tap do |logger|
      logger.level     = level
      logger.formatter = SIMPLE_FORMATTER
    end
  end


  attr_writer :logger

  private

  def logger(env = nil)
    @logger ||
      (defined?(::Rails) && ::Rails.logger) ||
      (env && !env["rack.logger"].is_a?(::Rack::NullLogger) && env["rack.logger"]) ||
      (env && env["rack.errors"] && self.class.mk_logger(env["rack.errors"]))      ||
      (@fallback_logger ||= self.class.mk_logger($stderr))
  end

  # generates the actual log string
  def log_state_change(env)
    info = env[::Rack::Timeout::ENV_INFO_KEY]
    level = STATE_LOG_LEVEL[info.state]
    logger(env).send(level) do
      s  = "source=rack-timeout"
      s << " id="      << info.id           if info.id
      s << " wait="    << info.ms(:wait)    if info.wait
      s << " timeout=" << info.ms(:timeout) if info.timeout
      s << " service=" << info.ms(:service) if info.service
      s << " state="   << info.state.to_s   if info.state
      s
    end
  end

end
