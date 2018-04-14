require 'rack/protection/version'
require 'rack'

module Rack
  module Protection
    autoload :AuthenticityToken,     'rack/protection/authenticity_token'
    autoload :Base,                  'rack/protection/base'
    autoload :CookieTossing,         'rack/protection/cookie_tossing'
    autoload :ContentSecurityPolicy, 'rack/protection/content_security_policy'
    autoload :EscapedParams,         'rack/protection/escaped_params'
    autoload :FormToken,             'rack/protection/form_token'
    autoload :FrameOptions,          'rack/protection/frame_options'
    autoload :HttpOrigin,            'rack/protection/http_origin'
    autoload :IPSpoofing,            'rack/protection/ip_spoofing'
    autoload :JsonCsrf,              'rack/protection/json_csrf'
    autoload :PathTraversal,         'rack/protection/path_traversal'
    autoload :RemoteReferrer,        'rack/protection/remote_referrer'
    autoload :RemoteToken,           'rack/protection/remote_token'
    autoload :SessionHijacking,      'rack/protection/session_hijacking'
    autoload :StrictTransport,       'rack/protection/strict_transport'
    autoload :XSSHeader,             'rack/protection/xss_header'

    def self.new(app, options = {})
      # does not include: RemoteReferrer, AuthenticityToken and FormToken
      except = Array options[:except]
      use_these = Array options[:use]

      if options.fetch(:without_session, false)
        except += [:session_hijacking, :remote_token]
      end

      Rack::Builder.new do
        # Off by default, unless added
        use ::Rack::Protection::AuthenticityToken,     options if use_these.include? :authenticity_token
        use ::Rack::Protection::CookieTossing,         options if use_these.include? :cookie_tossing
        use ::Rack::Protection::ContentSecurityPolicy, options if use_these.include? :content_security_policy
        use ::Rack::Protection::FormToken,             options if use_these.include? :form_token
        use ::Rack::Protection::RemoteReferrer,        options if use_these.include? :remote_referrer
        use ::Rack::Protection::StrictTransport,       options if use_these.include? :strict_transport

        # On by default, unless skipped
        use ::Rack::Protection::FrameOptions,          options unless except.include? :frame_options
        use ::Rack::Protection::HttpOrigin,            options unless except.include? :http_origin
        use ::Rack::Protection::IPSpoofing,            options unless except.include? :ip_spoofing
        use ::Rack::Protection::JsonCsrf,              options unless except.include? :json_csrf
        use ::Rack::Protection::PathTraversal,         options unless except.include? :path_traversal
        use ::Rack::Protection::RemoteToken,           options unless except.include? :remote_token
        use ::Rack::Protection::SessionHijacking,      options unless except.include? :session_hijacking
        use ::Rack::Protection::XSSHeader,             options unless except.include? :xss_header
        run app
      end.to_app
    end
  end
end
