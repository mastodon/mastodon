# frozen_string_literal: true
# encoding: utf-8
module Warden
  module Mixins
    module Common

      # Convenience method to access the session
      # :api: public
      def session
        env['rack.session']
      end # session

      # Alias :session to :raw_session since the former will be user API for storing scoped data.
      alias :raw_session :session

      # Convenience method to access the rack request.
      # :api: public
      def request
        @request ||= Rack::Request.new(@env)
      end # request

      # Provides a warden repository for cookies. Those are sent to the client
      # when the response is streamed back from the app.
      # :api: public
      def warden_cookies
        warn "warden_cookies was never functional and is going to be removed in next versions"
        env['warden.cookies'] ||= {}
      end # warden_cookies

      # Convenience method to access the rack request params
      # :api: public
      def params
        request.params
      end # params

      # Resets the session.  By using this non-hash like sessions can
      # be cleared by overwriting this method in a plugin
      # @api overwritable
      def reset_session!
        raw_session.clear
      end # reset_session!

    end # Common
  end # Mixins
end # Warden
