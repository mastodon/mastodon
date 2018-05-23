module Aws
  module Rest
    module Response
      class Parser

        def apply(response)
          # TODO : remove this unless check once response stubbing is fixed
          if rules = response.context.operation.output
            response.data = rules.shape.struct_class.new
            extract_status_code(rules, response)
            extract_headers(rules, response)
            extract_body(rules, response)
          else
            response.data = EmptyStructure.new
          end
        end

        private

        def extract_status_code(rules, response)
          status_code = StatusCode.new(rules)
          status_code.apply(response.context.http_response, response.data)
        end

        def extract_headers(rules, response)
          headers = Headers.new(rules)
          headers.apply(response.context.http_response, response.data)
        end

        def extract_body(rules, response)
          Body.new(parser_class(response), rules).
            apply(response.context.http_response.body, response.data)
        end

        def parser_class(response)
          protocol = response.context.config.api.metadata['protocol']
          case protocol
          when 'rest-xml' then Xml::Parser
          when 'rest-json' then Json::Parser
          when 'api-gateway' then Json::Parser
          else raise "unsupported protocol #{protocol}"
          end
        end

      end
    end
  end
end
