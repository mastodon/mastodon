require 'uri'

module Faraday
  class Adapter
    class EMSynchrony < Faraday::Adapter
      include EMHttp::Options

      dependency do
        require 'em-synchrony/em-http'
        require 'em-synchrony/em-multi'
        require 'fiber'
      end

      self.supports_parallel = true

      def self.setup_parallel_manager(options = {})
        ParallelManager.new
      end

      def call(env)
        super
        request = create_request(env)

        http_method = env[:method].to_s.downcase.to_sym

        # Queue requests for parallel execution.
        if env[:parallel_manager]
          env[:parallel_manager].add(request, http_method, request_config(env)) do |resp|
            save_response(env, resp.response_header.status, resp.response) do |resp_headers|
              resp.response_header.each do |name, value|
                resp_headers[name.to_sym] = value
              end
            end

            # Finalize the response object with values from `env`.
            env[:response].finish(env)
          end

        # Execute single request.
        else
          client = nil
          block = lambda { request.send(http_method, request_config(env)) }

          if !EM.reactor_running?
            EM.run do
              Fiber.new {
                client = block.call
                EM.stop
              }.resume
            end
          else
            client = block.call
          end

          raise client.error if client.error

          status = client.response_header.status
          reason = client.response_header.http_reason
          save_response(env, status, client.response, nil, reason) do |resp_headers|
            client.response_header.each do |name, value|
              resp_headers[name.to_sym] = value
            end
          end
        end

        @app.call env
      rescue Errno::ECONNREFUSED
        raise Error::ConnectionFailed, $!
      rescue EventMachine::Connectify::CONNECTError => err
        if err.message.include?("Proxy Authentication Required")
          raise Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        else
          raise Error::ConnectionFailed, err
        end
      rescue Errno::ETIMEDOUT => err
        raise Error::TimeoutError, err
      rescue RuntimeError => err
        if err.message == "connection closed by server"
          raise Error::ConnectionFailed, err
        else
          raise
        end
      rescue => err
        if defined?(OpenSSL) && OpenSSL::SSL::SSLError === err
          raise Faraday::SSLError, err
        else
          raise
        end
      end

      def create_request(env)
        EventMachine::HttpRequest.new(Utils::URI(env[:url].to_s), connection_config(env).merge(@connection_options))
      end
    end
  end
end

require 'faraday/adapter/em_synchrony/parallel_manager'

begin
  require 'openssl'
rescue LoadError
  warn "Warning: no such file to load -- openssl. Make sure it is installed if you want HTTPS support"
else
  require 'faraday/adapter/em_http_ssl_patch'
end if Faraday::Adapter::EMSynchrony.loaded?
