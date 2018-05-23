module Faraday
  class Adapter
    class Excon < Faraday::Adapter
      dependency 'excon'

      def call(env)
        super

        opts = {}
        if env[:url].scheme == 'https' && ssl = env[:ssl]
          opts[:ssl_verify_peer] = !!ssl.fetch(:verify, true)
          opts[:ssl_ca_path] = ssl[:ca_path] if ssl[:ca_path]
          opts[:ssl_ca_file] = ssl[:ca_file] if ssl[:ca_file]
          opts[:client_cert] = ssl[:client_cert] if ssl[:client_cert]
          opts[:client_key]  = ssl[:client_key]  if ssl[:client_key]
          opts[:certificate] = ssl[:certificate] if ssl[:certificate]
          opts[:private_key] = ssl[:private_key] if ssl[:private_key]

          # https://github.com/geemus/excon/issues/106
          # https://github.com/jruby/jruby-ossl/issues/19
          opts[:nonblock] = false
        end

        if ( req = env[:request] )
          if req[:timeout]
            opts[:read_timeout]      = req[:timeout]
            opts[:connect_timeout]   = req[:timeout]
            opts[:write_timeout]     = req[:timeout]
          end

          if req[:open_timeout]
            opts[:connect_timeout]   = req[:open_timeout]
          end

          if req[:proxy]
            opts[:proxy] = {
              :host     => req[:proxy][:uri].host,
              :hostname => req[:proxy][:uri].hostname,
              :port     => req[:proxy][:uri].port,
              :scheme   => req[:proxy][:uri].scheme,
              :user     => req[:proxy][:user],
              :password => req[:proxy][:password]
            }
          end
        end

        conn = create_connection(env, opts)

        resp = conn.request \
          :method  => env[:method].to_s.upcase,
          :headers => env[:request_headers],
          :body    => read_body(env)

        save_response(env, resp.status.to_i, resp.body, resp.headers, resp.reason_phrase)

        @app.call env
      rescue ::Excon::Errors::SocketError => err
        if err.message =~ /\btimeout\b/
          raise Error::TimeoutError, err
        elsif err.message =~ /\bcertificate\b/
          raise Faraday::SSLError, err
        else
          raise Error::ConnectionFailed, err
        end
      rescue ::Excon::Errors::Timeout => err
        raise Error::TimeoutError, err
      end

      def create_connection(env, opts)
        ::Excon.new(env[:url].to_s, opts.merge(@connection_options))
      end

      # TODO: support streaming requests
      def read_body(env)
        env[:body].respond_to?(:read) ? env[:body].read : env[:body]
      end
    end
  end
end
