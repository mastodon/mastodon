require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   Session Hijacking
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Session_hijacking
    #
    # Tracks request properties like the user agent in the session and empties
    # the session if those properties change. This essentially prevents attacks
    # from Firesheep. Since all headers taken into consideration can be
    # spoofed, too, this will not prevent determined hijacking attempts.
    class SessionHijacking < Base
      default_reaction :drop_session
      default_options :tracking_key => :tracking, :encrypt_tracking => true,
        :track => %w[HTTP_USER_AGENT HTTP_ACCEPT_LANGUAGE]

      def accepts?(env)
        session = session env
        key     = options[:tracking_key]
        if session.include? key
          session[key].all? { |k,v| v == encrypt(env[k]) }
        else
          session[key] = {}
          options[:track].each { |k| session[key][k] = encrypt(env[k]) }
        end
      end

      def encrypt(value)
        value = value.to_s.downcase
        options[:encrypt_tracking] ? super(value) : value
      end
    end
  end
end
