module Aws
  module Sigv4
    # Users that wish to configure static credentials can use the
    # `:access_key_id` and `:secret_access_key` constructor options.
    # @api private
    class Credentials

      # @option options [required, String] :access_key_id
      # @option options [required, String] :secret_access_key
      # @option options [String, nil] :session_token (nil)
      def initialize(options = {})
        if options[:access_key_id] && options[:secret_access_key]
          @access_key_id = options[:access_key_id]
          @secret_access_key = options[:secret_access_key]
          @session_token = options[:session_token]
        else
          msg = "expected both :access_key_id and :secret_access_key options"
          raise ArgumentError, msg
        end
      end

      # @return [String]
      attr_reader :access_key_id

      # @return [String]
      attr_reader :secret_access_key

      # @return [String, nil]
      attr_reader :session_token

      # @return [Boolean]
      def set?
        !!(access_key_id && secret_access_key)
      end

    end

    # Users that wish to configure static credentials can use the
    # `:access_key_id` and `:secret_access_key` constructor options.
    # @api private
    class StaticCredentialsProvider

      # @option options [Credentials] :credentials
      # @option options [String] :access_key_id
      # @option options [String] :secret_access_key
      # @option options [String] :session_token (nil)
      def initialize(options = {})
        @credentials = options[:credentials] ?
          options[:credentials] :
          Credentials.new(options)
      end

      # @return [Credentials]
      attr_reader :credentials

    end

  end
end
