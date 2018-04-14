module Aws
  module Stubbing
    module Protocols
      class RestJson < Rest

        def body_for(_, _, rules, data)
          Aws::Json::Builder.new(rules).serialize(data)
        end

        def stub_error(error_code)
          http_resp = Seahorse::Client::Http::Response.new
          http_resp.status_code = 400
          http_resp.body = <<-JSON.strip
{
  "code": #{error_code.inspect},
  "message": "stubbed-response-error-message"
}
          JSON
          http_resp
        end

      end
    end
  end
end
