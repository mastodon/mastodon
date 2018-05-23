require 'rack/content_length'
require 'rack/rewindable_input'

module Rack
  module Handler
    class CGI
      def self.run(app, options=nil)
        $stdin.binmode
        serve app
      end

      def self.serve(app)
        env = ENV.to_hash
        env.delete "HTTP_CONTENT_LENGTH"

        env[SCRIPT_NAME] = ""  if env[SCRIPT_NAME] == "/"

        env.update(
          RACK_VERSION      => Rack::VERSION,
          RACK_INPUT        => Rack::RewindableInput.new($stdin),
          RACK_ERRORS       => $stderr,
          RACK_MULTITHREAD  => false,
          RACK_MULTIPROCESS => true,
          RACK_RUNONCE      => true,
          RACK_URL_SCHEME   => ["yes", "on", "1"].include?(ENV[HTTPS]) ? "https" : "http"
        )

        env[QUERY_STRING] ||= ""
        env[HTTP_VERSION] ||= env[SERVER_PROTOCOL]
        env[REQUEST_PATH] ||= "/"

        status, headers, body = app.call(env)
        begin
          send_headers status, headers
          send_body body
        ensure
          body.close  if body.respond_to? :close
        end
      end

      def self.send_headers(status, headers)
        $stdout.print "Status: #{status}\r\n"
        headers.each { |k, vs|
          vs.split("\n").each { |v|
            $stdout.print "#{k}: #{v}\r\n"
          }
        }
        $stdout.print "\r\n"
        $stdout.flush
      end

      def self.send_body(body)
        body.each { |part|
          $stdout.print part
          $stdout.flush
        }
      end
    end
  end
end
