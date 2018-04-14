module Aws
  module Rest
    module Response
      class StatusCode

        # @param [Seahorse::Model::Shapes::ShapeRef] rules
        def initialize(rules)
          @rules = rules
        end

        # @param [Seahorse::Client::Http::Response] http_resp
        # @param [Hash, Struct] data
        def apply(http_resp, data)
          @rules.shape.members.each do |member_name, member_ref|
            if member_ref.location == 'statusCode'
              data[member_name] = http_resp.status_code
            end
          end
        end

      end
    end
  end
end
