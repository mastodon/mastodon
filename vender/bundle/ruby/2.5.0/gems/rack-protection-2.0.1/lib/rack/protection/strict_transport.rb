require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   Protects against against protocol downgrade attacks and cookie hijacking.
    # Supported browsers:: all
    # More infos::         https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
    #
    # browser will prevent any communications from being sent over HTTP
    # to the specified domain and will instead send all communications over HTTPS.
    # It also prevents HTTPS click through prompts on browsers.
    #
    # Options:
    #
    # max_age:: How long future requests to the domain should go over HTTPS; specified in seconds
    # include_subdomains:: If all present and future subdomains will be HTTPS
    # preload:: Allow this domain to be included in browsers HSTS preload list. See https://hstspreload.appspot.com/

    class StrictTransport < Base
      default_options :max_age => 31_536_000, :include_subdomains => false, :preload => false

      def strict_transport
        @strict_transport ||= begin
          strict_transport = 'max-age=' + options[:max_age].to_s
          strict_transport += '; includeSubDomains' if options[:include_subdomains]
          strict_transport += '; preload' if options[:preload]
          strict_transport.to_str
        end
      end

      def call(env)
        status, headers, body = @app.call(env)
        headers['Strict-Transport-Security'] ||= strict_transport
        [status, headers, body]
      end
    end
  end
end
