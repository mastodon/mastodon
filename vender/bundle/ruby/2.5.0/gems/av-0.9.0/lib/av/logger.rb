require "logger"

module Av
  module Logger
    def log message
      logger.info "[AV] #{message}" if options[:log]
    end
  
    def logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def logger=(logger)
      @logger = logger
    end
  end  
end
