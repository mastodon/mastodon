module Faraday
  class Adapter
    # EventMachine adapter is useful for either asynchronous requests
    # when in EM reactor loop or for making parallel requests in
    # synchronous code.
    class EMHttp < Faraday::Adapter
      module Options
        def connection_config(env)
          options = {}
          configure_proxy(options, env)
          configure_timeout(options, env)
          configure_socket(options, env)
          configure_ssl(options, env)
          options
        end

        def request_config(env)
          options = {
            :body => read_body(env),
            :head => env[:request_headers],
            # :keepalive => true,
            # :file => 'path/to/file', # stream data off disk
          }
          configure_compression(options, env)
          options
        end

        def read_body(env)
          body = env[:body]
          body.respond_to?(:read) ? body.read : body
        end

        def configure_proxy(options, env)
          if proxy = request_options(env)[:proxy]
            options[:proxy] = {
              :host => proxy[:uri].host,
              :port => proxy[:uri].port,
              :authorization => [proxy[:user], proxy[:password]]
            }
          end
        end

        def configure_socket(options, env)
          if bind = request_options(env)[:bind]
            options[:bind] = {
              :host => bind[:host],
              :port => bind[:port]
            }
          end
        end

        def configure_ssl(options, env)
          if env[:url].scheme == 'https' && env[:ssl]
            options[:ssl] = {
              :cert_chain_file => env[:ssl][:ca_file],
              :verify_peer => env[:ssl].fetch(:verify, true)
            }
          end
        end

        def configure_timeout(options, env)
          timeout, open_timeout = request_options(env).values_at(:timeout, :open_timeout)
          options[:connect_timeout] = options[:inactivity_timeout] = timeout
          options[:connect_timeout] = open_timeout if open_timeout
        end

        def configure_compression(options, env)
          if env[:method] == :get and not options[:head].key? 'accept-encoding'
            options[:head]['accept-encoding'] = 'gzip, compressed'
          end
        end

        def request_options(env)
          env[:request]
        end
      end

      include Options

      dependency 'em-http'

      self.supports_parallel = true

      def self.setup_parallel_manager(options = nil)
        Manager.new
      end

      def call(env)
        super
        perform_request env
        @app.call env
      end

      def perform_request(env)
        if parallel?(env)
          manager = env[:parallel_manager]
          manager.add {
            perform_single_request(env).
              callback { env[:response].finish(env) }
          }
        else
          unless EventMachine.reactor_running?
            error = nil
            # start EM, block until request is completed
            EventMachine.run do
              perform_single_request(env).
                callback { EventMachine.stop }.
                errback { |client|
                  error = error_message(client)
                  EventMachine.stop
                }
            end
            raise_error(error) if error
          else
            # EM is running: instruct upstream that this is an async request
            env[:parallel_manager] = true
            perform_single_request(env).
              callback { env[:response].finish(env) }.
              errback {
                # TODO: no way to communicate the error in async mode
                raise NotImplementedError
              }
          end
        end
      rescue EventMachine::Connectify::CONNECTError => err
        if err.message.include?("Proxy Authentication Required")
          raise Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        else
          raise Error::ConnectionFailed, err
        end
      rescue => err
        if defined?(OpenSSL) && OpenSSL::SSL::SSLError === err
          raise Faraday::SSLError, err
        else
          raise
        end
      end

      # TODO: reuse the connection to support pipelining
      def perform_single_request(env)
        req = create_request(env)
        req.setup_request(env[:method], request_config(env)).callback { |client|
          status = client.response_header.status
          reason = client.response_header.http_reason
          save_response(env, status, client.response, nil, reason) do |resp_headers|
            client.response_header.each do |name, value|
              resp_headers[name.to_sym] = value
            end
          end
        }
      end

      def create_request(env)
        EventMachine::HttpRequest.new(env[:url], connection_config(env).merge(@connection_options))
      end

      def error_message(client)
        client.error or "request failed"
      end

      def raise_error(msg)
        errklass = Faraday::Error::ClientError
        if msg == Errno::ETIMEDOUT
          errklass = Faraday::Error::TimeoutError
          msg = "request timed out"
        elsif msg == Errno::ECONNREFUSED
          errklass = Faraday::Error::ConnectionFailed
          msg = "connection refused"
        elsif msg == "connection closed by server"
          errklass = Faraday::Error::ConnectionFailed
        end
        raise errklass, msg
      end

      def parallel?(env)
        !!env[:parallel_manager]
      end

      # The parallel manager is designed to start an EventMachine loop
      # and block until all registered requests have been completed.
      class Manager
        def initialize
          reset
        end

        def reset
          @registered_procs = []
          @num_registered = 0
          @num_succeeded = 0
          @errors = []
          @running = false
        end

        def running?() @running end

        def add
          if running?
            perform_request { yield }
          else
            @registered_procs << Proc.new
          end
          @num_registered += 1
        end

        def run
          if @num_registered > 0
            @running = true
            EventMachine.run do
              @registered_procs.each do |proc|
                perform_request(&proc)
              end
            end
            if @errors.size > 0
              raise Faraday::Error::ClientError, @errors.first || "connection failed"
            end
          end
        ensure
          reset
        end

        def perform_request
          client = yield
          client.callback { @num_succeeded += 1; check_finished }
          client.errback { @errors << client.error; check_finished }
        end

        def check_finished
          if @num_succeeded + @errors.size == @num_registered
            EventMachine.stop
          end
        end
      end
    end
  end
end

begin
  require 'openssl'
rescue LoadError
  warn "Warning: no such file to load -- openssl. Make sure it is installed if you want HTTPS support"
else
  require 'faraday/adapter/em_http_ssl_patch'
end if Faraday::Adapter::EMHttp.loaded?
