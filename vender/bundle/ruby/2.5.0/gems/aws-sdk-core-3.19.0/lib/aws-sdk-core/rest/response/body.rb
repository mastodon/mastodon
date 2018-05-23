module Aws
  module Rest
    module Response
      class Body

        include Seahorse::Model::Shapes

        # @param [Class] parser_class
        # @param [Seahorse::Model::ShapeRef] rules
        def initialize(parser_class, rules)
          @parser_class = parser_class
          @rules = rules
        end

        # @param [IO] body
        # @param [Hash, Struct] data
        def apply(body, data)
          if streaming?
            data[@rules[:payload]] = body
          elsif @rules[:payload]
            data[@rules[:payload]] = parse(body.read, @rules[:payload_member])
          elsif !@rules.shape.member_names.empty?
            parse(body.read, @rules, data)
          end
        end

        private

        def streaming?
          @rules[:payload] && (
            BlobShape === @rules[:payload_member].shape ||
            StringShape === @rules[:payload_member].shape
          )
        end

        def parse(body, rules, target = nil)
          @parser_class.new(rules).parse(body, target) if body.size > 0
        end

      end
    end
  end
end
