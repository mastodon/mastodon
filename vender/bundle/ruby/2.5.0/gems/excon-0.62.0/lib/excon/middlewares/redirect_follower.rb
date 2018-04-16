# frozen_string_literal: true
module Excon
  module Middleware
    class RedirectFollower < Excon::Middleware::Base

      def get_header(datum, header)
        _, header_value = datum[:response][:headers].detect do |key, value|
          key.casecmp(header) == 0
        end
        header_value
      end

      def response_call(datum)
        if datum.has_key?(:response)
          case datum[:response][:status]
          when 301, 302, 303, 307, 308
            uri_parser = datum[:uri_parser] || Excon.defaults[:uri_parser]

            location = get_header(datum, 'Location')
            base_uri = Excon::Utils.request_uri(datum)
            uri = uri_parser.join(base_uri, location)

            # delete old/redirect response
            response = datum.delete(:response)

            params = datum.dup
            params.delete(:connection)
            params.delete(:password)
            params.delete(:stack)
            params.delete(:user)

            if [301, 302, 303].include?(response[:status])
              params[:method] = :get
              params.delete(:body)
              params[:headers].delete('Content-Length')
            end
            params[:headers] = datum[:headers].dup
            params[:headers].delete('Authorization')
            params[:headers].delete('Proxy-Connection')
            params[:headers].delete('Proxy-Authorization')
            params[:headers].delete('Host')
            params.merge!(
              :scheme     => uri.scheme || datum[:scheme],
              :host       => uri.host   || datum[:host],
              :hostname   => uri.hostname || datum[:hostname],
              :port       => uri.port   || datum[:port],
              :path       => uri.path,
              :query      => uri.query
            )

            params.merge!(:user => Utils.unescape_uri(uri.user)) if uri.user
            params.merge!(:password => Utils.unescape_uri(uri.password)) if uri.password

            response = Excon::Connection.new(params).request
            datum.merge!({:response => response.data})
          else
            @stack.response_call(datum)
          end
        else
          @stack.response_call(datum)
        end
      end
    end
  end
end
