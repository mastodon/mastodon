require 'rack/utils'

module Doorkeeper
  module OAuth
    module Authorization
      class URIBuilder
        class << self
          def uri_with_query(url, parameters = {})
            uri            = URI.parse(url)
            original_query = Rack::Utils.parse_query(uri.query)
            uri.query      = build_query(original_query.merge(parameters))
            uri.to_s
          end

          def uri_with_fragment(url, parameters = {})
            uri = URI.parse(url)
            uri.fragment = build_query(parameters)
            uri.to_s
          end

          private

          def build_query(parameters = {})
            parameters = parameters.reject { |_, v| v.blank? }
            Rack::Utils.build_query parameters
          end
        end
      end
    end
  end
end
