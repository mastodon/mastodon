require 'logger'

module Concurrent
  module Concern

    # Include where logging is needed
    #
    # @!visibility private
    module Logging
      include Logger::Severity

      # Logs through {Concurrent.global_logger}, it can be overridden by setting @logger
      # @param [Integer] level one of Logger::Severity constants
      # @param [String] progname e.g. a path of an Actor
      # @param [String, nil] message when nil block is used to generate the message
      # @yieldreturn [String] a message
      def log(level, progname, message = nil, &block)
        #NOTE: Cannot require 'concurrent/configuration' above due to circular references.
        #      Assume that the gem has been initialized if we've gotten this far.
        (@logger || Concurrent.global_logger).call level, progname, message, &block
      rescue => error
        $stderr.puts "`Concurrent.configuration.logger` failed to log #{[level, progname, message, block]}\n" +
          "#{error.message} (#{error.class})\n#{error.backtrace.join "\n"}"
      end
    end
  end
end
