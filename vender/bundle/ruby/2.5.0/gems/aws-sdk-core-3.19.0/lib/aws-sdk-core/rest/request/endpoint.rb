require 'uri'

module Aws
  module Rest
    module Request
      class Endpoint

        # @param [Seahorse::Model::Shapes::ShapeRef] rules
        # @param [String] request_uri_pattern
        def initialize(rules, request_uri_pattern)
          @rules = rules
          request_uri_pattern.split('?').tap do |path_part, query_part|
            @path_pattern = path_part
            @query_prefix = query_part
          end
        end

        # @param [URI::HTTPS,URI::HTTP] base_uri
        # @param [Hash,Struct] params
        # @return [URI::HTTPS,URI::HTTP]
        def uri(base_uri, params)
          uri = URI.parse(base_uri.to_s)
          apply_path_params(uri, params)
          apply_querystring_params(uri, params)
          uri
        end

        private

        def apply_path_params(uri, params)
          path = uri.path.sub(/\/$/, '') + @path_pattern.split('?')[0]
          uri.path = path.gsub(/{.+?}/) do |placeholder|
            param_value_for_placeholder(placeholder, params)
          end
        end

        def param_value_for_placeholder(placeholder, params)
          value = params[param_name(placeholder)].to_s
          placeholder.include?('+') ?
            value.gsub(/[^\/]+/) { |v| escape(v) } :
            escape(value)
        end

        def param_name(placeholder)
          location_name = placeholder.gsub(/[{}+]/,'')
          param_name, _ = @rules.shape.member_by_location_name(location_name)
          param_name
        end

        def apply_querystring_params(uri, params)
          # collect params that are supposed to be part of the query string
          parts = @rules.shape.members.inject([]) do |prts, (member_name, member_ref)|
            if member_ref.location == 'querystring' && !params[member_name].nil?
              prts << [member_ref, params[member_name]]
            end
            prts
          end
          querystring = QuerystringBuilder.new.build(parts)
          querystring = [@query_prefix, querystring == '' ? nil : querystring].compact.join('&')
          querystring = nil if querystring == ''
          uri.query = querystring
        end

        def escape(string)
          Seahorse::Util.uri_escape(string)
        end

      end
    end
  end
end
