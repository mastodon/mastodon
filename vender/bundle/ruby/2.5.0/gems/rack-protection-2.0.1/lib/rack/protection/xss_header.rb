require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   Non-permanent XSS
    # Supported browsers:: Internet Explorer 8+ and Chrome
    # More infos::         http://blogs.msdn.com/b/ie/archive/2008/07/01/ie8-security-part-iv-the-xss-filter.aspx
    #
    # Sets X-XSS-Protection header to tell the browser to block attacks.
    #
    # Options:
    # xss_mode:: How the browser should prevent the attack (default: :block)
    class XSSHeader < Base
      default_options :xss_mode => :block, :nosniff => true

      def call(env)
        status, headers, body = @app.call(env)
        headers['X-XSS-Protection']       ||= "1; mode=#{options[:xss_mode]}" if html? headers
        headers['X-Content-Type-Options'] ||= 'nosniff'                       if options[:nosniff]
        [status, headers, body]
      end
    end
  end
end
