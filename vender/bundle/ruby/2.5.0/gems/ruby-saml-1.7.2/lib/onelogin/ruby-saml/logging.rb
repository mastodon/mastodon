require 'logger'

# Simplistic log class when we're running in Rails
module OneLogin
  module RubySaml
    class Logging
      DEFAULT_LOGGER = ::Logger.new(STDOUT)

      def self.logger
        @logger || (defined?(::Rails) && Rails.respond_to?(:logger) && Rails.logger) || DEFAULT_LOGGER
      end

      def self.logger=(logger)
        @logger = logger
      end

      def self.debug(message)
        return if !!ENV["ruby-saml/testing"]

        logger.debug message
      end

      def self.info(message)
        return if !!ENV["ruby-saml/testing"]

        logger.info message
      end
    end
  end
end
