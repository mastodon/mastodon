require 'logger'

module Excon
  class LoggingInstrumentor
    # Returns the Logger object for the LoggingInstrumentor. If one doesn't
    # already exist, then one will be created using $stderr as the output
    # stream.
    #
    def self.logger
      @logger ||= Logger.new($stderr)
    end

    # Sets the logger object for the LoggingInstrumentor.
    #
    def self.logger=(logger)
      @logger = logger
    end

    def self.instrument(name, params = {}, &block)
      params = params.dup

      # reduce duplication/noise of output
      params.delete(:connection)
      params.delete(:stack)

      if params.has_key?(:headers) && params[:headers].has_key?('Authorization')
        params[:headers] = params[:headers].dup
        params[:headers]['Authorization'] = "REDACTED"
      end

      if params.has_key?(:password)
        params[:password] = "REDACTED"
      end

      if name.include?('request')
        info = "request: " + params[:scheme] + "://" + File.join(params[:host], params[:path])

        if params[:query]
          info << "?"

          if params[:query].is_a?(Hash)
            info << params.to_a.map{ |key,value| "#{key}=#{value}" }.join('&')
          else
            info << params[:query]
          end
        end
      else
        response_type = name.split('.').last
        if params[:body]
          info = "#{response_type}: " + params[:body]
        end
      end

      self.logger.log(logger.level, info) if info

      yield if block_given?
    end
  end
end
