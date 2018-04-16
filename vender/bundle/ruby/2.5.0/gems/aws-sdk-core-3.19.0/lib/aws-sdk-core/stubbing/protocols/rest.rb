module Aws
  module Stubbing
    module Protocols
      class Rest

        include Seahorse::Model::Shapes

        def stub_data(api, operation, data)
          resp = new_http_response
          apply_status_code(operation, resp, data)
          apply_headers(operation, resp, data)
          apply_body(api, operation, resp, data)
          resp
        end

        private

        def new_http_response
          resp = Seahorse::Client::Http::Response.new
          resp.status_code = 200
          resp.headers["x-amzn-RequestId"] = "stubbed-request-id"
          resp
        end

        def apply_status_code(operation, resp, data)
          operation.output.shape.members.each do |member_name, member_ref|
            if member_ref.location == 'statusCode'
              resp.status_code = data[member_name] if data.key?(member_name)
            end
          end
        end

        def apply_headers(operation, resp, data)
          Aws::Rest::Request::Headers.new(operation.output).apply(resp, data)
        end

        def apply_body(api, operation, resp, data)
          resp.body = build_body(api, operation, data)
        end

        def build_body(api, operation, data)
          rules = operation.output
          if head_operation(operation)
            ""
          elsif streaming?(rules)
            data[rules[:payload]]
          elsif rules[:payload]
            body_for(api, operation, rules[:payload_member], data[rules[:payload]])
          else
            filtered = Seahorse::Model::Shapes::ShapeRef.new(
              shape: Seahorse::Model::Shapes::StructureShape.new.tap do |s|
                rules.shape.members.each do |member_name, member_ref|
                  s.add_member(member_name, member_ref) if member_ref.location.nil?
                end
              end
            )
            body_for(api, operation, filtered, data)
          end
        end

        def streaming?(ref)
          if ref[:payload]
            case ref[:payload_member].shape
            when StringShape then true
            when BlobShape then true
            else false
            end
          else
            false
          end
        end

        def head_operation(operation)
          operation.http_method == "HEAD"
        end

      end
    end
  end
end
