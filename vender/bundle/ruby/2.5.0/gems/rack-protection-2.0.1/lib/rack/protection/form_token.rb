require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   CSRF
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Cross-site_request_forgery
    #
    # Only accepts submitted forms if a given access token matches the token
    # included in the session. Does not expect such a token from Ajax request.
    #
    # This middleware is not used when using the Rack::Protection collection,
    # since it might be a security issue, depending on your application
    #
    # Compatible with rack-csrf.
    class FormToken < AuthenticityToken
      def accepts?(env)
        env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest" or super
      end
    end
  end
end
