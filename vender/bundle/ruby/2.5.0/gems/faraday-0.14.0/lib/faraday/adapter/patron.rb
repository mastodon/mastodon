module Faraday
  class Adapter
    class Patron < Faraday::Adapter
      dependency 'patron'

      def call(env)
        super
        # TODO: support streaming requests
        env[:body] = env[:body].read if env[:body].respond_to? :read

        session = @session ||= create_session
        configure_ssl(session, env[:ssl]) if env[:url].scheme == 'https' and env[:ssl]

        if req = env[:request]
          session.timeout = session.connect_timeout = req[:timeout] if req[:timeout]
          session.connect_timeout = req[:open_timeout]              if req[:open_timeout]

          if proxy = req[:proxy]
            proxy_uri = proxy[:uri].dup
            proxy_uri.user = proxy[:user] && Utils.escape(proxy[:user]).gsub('+', '%20')
            proxy_uri.password = proxy[:password] && Utils.escape(proxy[:password]).gsub('+', '%20')
            session.proxy = proxy_uri.to_s
          end
        end

        response = begin
          data = env[:body] ? env[:body].to_s : nil
          session.request(env[:method], env[:url].to_s, env[:request_headers], :data => data)
        rescue Errno::ECONNREFUSED, ::Patron::ConnectionFailed
          raise Error::ConnectionFailed, $!
        end

        # Remove the "HTTP/1.1 200", leaving just the reason phrase
        reason_phrase = response.status_line.gsub(/^.* \d{3} /, '')

        save_response(env, response.status, response.body, response.headers, reason_phrase)

        @app.call env
      rescue ::Patron::TimeoutError => err
        if connection_timed_out_message?(err.message)
          raise Faraday::Error::ConnectionFailed, err
        else
          raise Faraday::Error::TimeoutError, err
        end
      rescue ::Patron::Error => err
        if err.message.include?("code 407")
          raise Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        else
          raise Error::ConnectionFailed, err
        end
      end

      if loaded? && defined?(::Patron::Request::VALID_ACTIONS)
        # HAX: helps but doesn't work completely
        # https://github.com/toland/patron/issues/34
        ::Patron::Request::VALID_ACTIONS.tap do |actions|
          if actions[0].is_a?(Symbol)
            actions << :patch unless actions.include? :patch
            actions << :options unless actions.include? :options
          else
            # Patron 0.4.20 and up
            actions << "PATCH" unless actions.include? "PATCH"
            actions << "OPTIONS" unless actions.include? "OPTIONS"
          end
        end
      end

      def create_session
        session = ::Patron::Session.new
        @config_block.call(session) if @config_block
        session
      end

      def configure_ssl(session, ssl)
        if ssl.fetch(:verify, true)
          session.cacert = ssl[:ca_file]
        else
          session.insecure = true
        end
      end

      private

      CURL_TIMEOUT_MESSAGES = [ "Connection time-out",
          "Connection timed out",
          "Timed out before name resolve",
          "server connect has timed out",
          "Resolving timed out",
          "name lookup timed out",
          "timed out before SSL",
          "connect() timed out"
        ].freeze

      def connection_timed_out_message?(message)
        CURL_TIMEOUT_MESSAGES.any? { |curl_message| message.include?(curl_message) }
      end

    end
  end
end
