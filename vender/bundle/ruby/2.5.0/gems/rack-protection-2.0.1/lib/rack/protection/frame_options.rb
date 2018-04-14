require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   Clickjacking
    # Supported browsers:: Internet Explorer 8, Firefox 3.6.9, Opera 10.50,
    #                      Safari 4.0, Chrome 4.1.249.1042 and later
    # More infos::         https://developer.mozilla.org/en/The_X-FRAME-OPTIONS_response_header
    #
    # Sets X-Frame-Options header to tell the browser avoid embedding the page
    # in a frame.
    #
    # Options:
    #
    # frame_options:: Defines who should be allowed to embed the page in a
    #                 frame. Use :deny to forbid any embedding, :sameorigin
    #                 to allow embedding from the same origin (default).
    class FrameOptions < Base
      default_options :frame_options => :sameorigin

      def frame_options
        @frame_options ||= begin
          frame_options = options[:frame_options]
          frame_options = options[:frame_options].to_s.upcase unless frame_options.respond_to? :to_str
          frame_options.to_str
        end
      end

      def call(env)
        status, headers, body        = @app.call(env)
        headers['X-Frame-Options'] ||= frame_options if html? headers
        [status, headers, body]
      end
    end
  end
end
