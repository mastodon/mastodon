require 'fcgi'
require 'socket'
require 'rack/content_length'
require 'rack/rewindable_input'

if defined? FCGI::Stream
  class FCGI::Stream
    alias _rack_read_without_buffer read

    def read(n, buffer=nil)
      buf = _rack_read_without_buffer n
      buffer.replace(buf.to_s)  if buffer
      buf
    end
  end
end

module Rack
  module Handler
    class FastCGI
      def self.run(app, options={})
        if options[:File]
          STDIN.reopen(UNIXServer.new(options[:File]))
        elsif options[:Port]
          STDIN.reopen(TCPServer.new(options[:Host], options[:Port]))
        end
        FCGI.each { |request|
          serve request, app
        }
      end

      def self.valid_options
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 8080)",
          "File=PATH" => "Creates a Domain socket at PATH instead of a TCP socket. Ignores Host and Port if set.",
        }
      end

      def self.serve(request, app)
        env = request.env
        env.delete "HTTP_CONTENT_LENGTH"

        env[SCRIPT_NAME] = ""  if env[SCRIPT_NAME] == "/"

        rack_input = RewindableInput.new(request.in)

        env.update(
          RACK_VERSION      => Rack::VERSION,
          RACK_INPUT        => rack_input,
          RACK_ERRORS       => request.err,
          RACK_MULTITHREAD  => false,
          RACK_MULTIPROCESS => true,
          RACK_RUNONCE      => false,
          RACK_URL_SCHEME   => ["yes", "on", "1"].include?(env[HTTPS]) ? "https" : "http"
        )

        env[QUERY_STRING] ||= ""
        env[HTTP_VERSION] ||= env[SERVER_PROTOCOL]
        env[REQUEST_PATH] ||= "/"
        env.delete "CONTENT_TYPE"  if env["CONTENT_TYPE"] == ""
        env.delete "CONTENT_LENGTH"  if env["CONTENT_LENGTH"] == ""

        begin
          status, headers, body = app.call(env)
          begin
            send_headers request.out, status, headers
            send_body request.out, body
          ensure
            body.close  if body.respond_to? :close
          end
        ensure
          rack_input.close
          request.finish
        end
      end

      def self.send_headers(out, status, headers)
        out.print "Status: #{status}\r\n"
        headers.each { |k, vs|
          vs.split("\n").each { |v|
            out.print "#{k}: #{v}\r\n"
          }
        }
        out.print "\r\n"
        out.flush
      end

      def self.send_body(out, body)
        body.each { |part|
          out.print part
          out.flush
        }
      end
    end
  end
end
