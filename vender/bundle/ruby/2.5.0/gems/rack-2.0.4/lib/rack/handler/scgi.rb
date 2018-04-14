require 'scgi'
require 'stringio'
require 'rack/content_length'
require 'rack/chunked'

module Rack
  module Handler
    class SCGI < ::SCGI::Processor
      attr_accessor :app

      def self.run(app, options=nil)
        options[:Socket] = UNIXServer.new(options[:File]) if options[:File]
        new(options.merge(:app=>app,
                          :host=>options[:Host],
                          :port=>options[:Port],
                          :socket=>options[:Socket])).listen
      end

      def self.valid_options
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 8080)",
        }
      end

      def initialize(settings = {})
        @app = settings[:app]
        super(settings)
      end

      def process_request(request, input_body, socket)
        env = Hash[request]
        env.delete "HTTP_CONTENT_TYPE"
        env.delete "HTTP_CONTENT_LENGTH"
        env[REQUEST_PATH], env[QUERY_STRING] = env["REQUEST_URI"].split('?', 2)
        env[HTTP_VERSION] ||= env[SERVER_PROTOCOL]
        env[PATH_INFO] = env[REQUEST_PATH]
        env[QUERY_STRING] ||= ""
        env[SCRIPT_NAME] = ""

        rack_input = StringIO.new(input_body, encoding: Encoding::BINARY)

        env.update(
          RACK_VERSION      => Rack::VERSION,
          RACK_INPUT        => rack_input,
          RACK_ERRORS       => $stderr,
          RACK_MULTITHREAD  => true,
          RACK_MULTIPROCESS => true,
          RACK_RUNONCE      => false,
          RACK_URL_SCHEME   => ["yes", "on", "1"].include?(env[HTTPS]) ? "https" : "http"
        )

        status, headers, body = app.call(env)
        begin
          socket.write("Status: #{status}\r\n")
          headers.each do |k, vs|
            vs.split("\n").each { |v| socket.write("#{k}: #{v}\r\n")}
          end
          socket.write("\r\n")
          body.each {|s| socket.write(s)}
        ensure
          body.close if body.respond_to? :close
        end
      end
    end
  end
end
