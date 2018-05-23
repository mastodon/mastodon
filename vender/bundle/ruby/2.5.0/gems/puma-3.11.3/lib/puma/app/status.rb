module Puma
  module App
    class Status
      def initialize(cli)
        @cli = cli
        @auth_token = nil
      end
      OK_STATUS = '{ "status": "ok" }'.freeze

      attr_accessor :auth_token

      def authenticate(env)
        return true unless @auth_token
        env['QUERY_STRING'].to_s.split(/&;/).include?("token=#{@auth_token}")
      end

      def rack_response(status, body, content_type='application/json')
        headers = {
          'Content-Type' => content_type,
          'Content-Length' => body.bytesize.to_s
        }

        [status, headers, [body]]
      end

      def call(env)
        unless authenticate(env)
          return rack_response(403, 'Invalid auth token', 'text/plain')
        end

        case env['PATH_INFO']
        when /\/stop$/
          @cli.stop
          return rack_response(200, OK_STATUS)

        when /\/halt$/
          @cli.halt
          return rack_response(200, OK_STATUS)

        when /\/restart$/
          @cli.restart
          return rack_response(200, OK_STATUS)

        when /\/phased-restart$/
          if !@cli.phased_restart
            return rack_response(404, '{ "error": "phased restart not available" }')
          else
            return rack_response(200, OK_STATUS)
          end

        when /\/reload-worker-directory$/
          if !@cli.send(:reload_worker_directory)
            return rack_response(404, '{ "error": "reload_worker_directory not available" }')
          else
            return rack_response(200, OK_STATUS)
          end

        when /\/gc$/
          GC.start
          return rack_response(200, OK_STATUS)

        when /\/gc-stats$/
          json = "{" + GC.stat.map { |k, v| "\"#{k}\": #{v}" }.join(",") + "}"
          return rack_response(200, json)

        when /\/stats$/
          return rack_response(200, @cli.stats)
        else
          rack_response 404, "Unsupported action", 'text/plain'
        end
      end
    end
  end
end
