module Aws
  module Rest
    module Request
      class Body

        include Seahorse::Model::Shapes

        # @param [Class] serializer_class
        # @param [Seahorse::Model::ShapeRef] rules
        def initialize(serializer_class, rules)
          @serializer_class = serializer_class
          @rules = rules
        end

        # @param [Seahorse::Client::Http::Request] http_req
        # @param [Hash] params
        def apply(http_req, params)
          http_req.body = build_body(params)
        end

        private

        def build_body(params)
          if streaming?
            params[@rules[:payload]]
          elsif @rules[:payload]
            params = params[@rules[:payload]]
            serialize(@rules[:payload_member], params) if params
          else
            params = body_params(params)
            serialize(@rules, params) unless params.empty?
          end
        end

        def streaming?
          @rules[:payload] && (
            BlobShape === @rules[:payload_member].shape ||
            StringShape === @rules[:payload_member].shape
          )
        end

        def serialize(rules, params)
          @serializer_class.new(rules).serialize(params)
        end

        def body_params(params)
          @rules.shape.members.inject({}) do |hash, (member_name, member_ref)|
            if !member_ref.location && params.key?(member_name)
              hash[member_name] = params[member_name]
            end
            hash
          end
        end

      end
    end
  end
end
