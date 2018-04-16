require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   CSRF
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Cross-site_request_forgery
    #
    # Does not accept unsafe HTTP requests if the Referer [sic] header is set to
    # a different host.
    class RemoteReferrer < Base
      default_reaction :deny

      def accepts?(env)
        safe?(env) or referrer(env) == Request.new(env).host
      end
    end
  end
end
