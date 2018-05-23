require_relative '../../query'

module Aws
  module Plugins
    module Protocols
      class EC2 < Seahorse::Client::Plugin

        class Handler < Aws::Query::Handler

          def apply_params(param_list, params, rules)
            Aws::Query::EC2ParamBuilder.new(param_list).apply(rules, params)
          end

          def parse_xml(context)
            if rules = context.operation.output
              parser = Xml::Parser.new(rules)
              data = parser.parse(xml(context)) do |path, value|
                if path.size == 2 && path.last == 'requestId'
                  context.metadata[:request_id] = value
                end
              end
              data
            else
              EmptyStructure.new
            end
          end

        end

        handler(Handler)
        handler(Xml::ErrorHandler, step: :sign)

      end
    end
  end
end
