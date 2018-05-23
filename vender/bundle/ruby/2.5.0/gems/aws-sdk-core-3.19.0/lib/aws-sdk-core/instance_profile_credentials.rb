require 'json'
require 'time'
require 'net/http'

module Aws
  class InstanceProfileCredentials

    include CredentialProvider
    include RefreshingCredentials

    # @api private
    class Non200Response < RuntimeError; end

    # These are the errors we trap when attempting to talk to the
    # instance metadata service.  Any of these imply the service
    # is not present, no responding or some other non-recoverable
    # error.
    # @api private
    NETWORK_ERRORS = [
      Errno::EHOSTUNREACH,
      Errno::ECONNREFUSED,
      Errno::EHOSTDOWN,
      Errno::ENETUNREACH,
      SocketError,
      Timeout::Error,
      Non200Response,
    ]

    # @param [Hash] options
    # @option options [Integer] :retries (5) Number of times to retry
    #   when retrieving credentials.
    # @option options [String] :ip_address ('169.254.169.254')
    # @option options [Integer] :port (80)
    # @option options [Float] :http_open_timeout (5)
    # @option options [Float] :http_read_timeout (5)
    # @option options [Numeric, Proc] :delay By default, failures are retried
    #   with exponential back-off, i.e. `sleep(1.2 ** num_failures)`. You can
    #   pass a number of seconds to sleep between failed attempts, or
    #   a Proc that accepts the number of failures.
    # @option options [IO] :http_debug_output (nil) HTTP wire
    #   traces are sent to this object.  You can specify something
    #   like $stdout.
    def initialize options = {}
      @retries = options[:retries] || 5
      @ip_address = options[:ip_address] || '169.254.169.254'
      @port = options[:port] || 80
      @http_open_timeout = options[:http_open_timeout] || 5
      @http_read_timeout = options[:http_read_timeout] || 5
      @http_debug_output = options[:http_debug_output]
      @backoff = backoff(options[:backoff])
      super
    end

    # @return [Integer] The number of times to retry failed attempts to
    #   fetch credentials from the instance metadata service. Defaults to 0.
    attr_reader :retries

    private

    def backoff(backoff)
      case backoff
      when Proc then backoff
      when Numeric then lambda { |_| sleep(backoff) }
      else lambda { |num_failures| Kernel.sleep(1.2 ** num_failures) }
      end
    end

    def refresh
      # Retry loading credentials up to 3 times is the instance metadata
      # service is responding but is returning invalid JSON documents
      # in response to the GET profile credentials call.
      retry_errors([JSON::ParserError, StandardError], max_retries: 3) do
        c = JSON.parse(get_credentials.to_s)
        @credentials = Credentials.new(
          c['AccessKeyId'],
          c['SecretAccessKey'],
          c['Token']
        )
        @expiration = c['Expiration'] ? Time.parse(c['Expiration']) : nil
      end
    end

    def get_credentials
      # Retry loading credentials a configurable number of times if
      # the instance metadata service is not responding.
      if _metadata_disabled?
        '{}'
      else
        begin
          retry_errors(NETWORK_ERRORS, max_retries: @retries) do
            open_connection do |conn|
              path = '/latest/meta-data/iam/security-credentials/'
              profile_name = http_get(conn, path).lines.first.strip
              http_get(conn, path + profile_name)
            end
          end
        rescue
          '{}'
        end
      end
    end

    def _metadata_disabled?
      flag = ENV["AWS_EC2_METADATA_DISABLED"]
      !flag.nil? && flag.downcase == "true"
    end

    def open_connection
      http = Net::HTTP.new(@ip_address, @port, nil)
      http.open_timeout = @http_open_timeout
      http.read_timeout = @http_read_timeout
      http.set_debug_output(@http_debug_output) if @http_debug_output
      http.start
      yield(http).tap { http.finish }
    end

    def http_get(connection, path)
      response = connection.request(Net::HTTP::Get.new(path))
      if response.code.to_i == 200
        response.body
      else
        raise Non200Response
      end
    end

    def retry_errors(error_classes, options = {}, &block)
      max_retries = options[:max_retries]
      retries = 0
      begin
        yield
      rescue *error_classes
        if retries < max_retries
          @backoff.call(retries)
          retries += 1
          retry
        else
          raise
        end
      end
    end

  end
end
