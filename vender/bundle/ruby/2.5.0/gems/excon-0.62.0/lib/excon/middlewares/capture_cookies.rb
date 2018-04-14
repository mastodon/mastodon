# frozen_string_literal: true
module Excon
  module Middleware
    class CaptureCookies < Excon::Middleware::Base

      def extract_cookies_from_set_cookie(set_cookie)
        set_cookie.split(',').map { |full| full.split(';').first.strip }.join('; ')
      end

      def get_header(datum, header)
        _, header_value = datum[:response][:headers].detect do |key, value|
          key.casecmp(header) == 0
        end
        header_value
      end

      def response_call(datum)
        cookie = get_header(datum, 'Set-Cookie')
        if cookie
          cookie = extract_cookies_from_set_cookie(cookie)
          unless datum[:headers].key?("Cookie")
            datum[:headers]["Cookie"] = cookie
          else
            original_cookies = datum[:headers]["Cookie"]
            datum[:headers]["Cookie"] = original_cookies.empty? ? cookie : [original_cookies,cookie].join('; ')
          end
        end
        super(datum)
      end
    end
  end
end
