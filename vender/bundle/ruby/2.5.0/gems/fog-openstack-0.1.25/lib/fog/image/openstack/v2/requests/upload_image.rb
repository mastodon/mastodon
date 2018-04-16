module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def upload_image(image_id, body, params = {})
            request_hash = {
              :headers => {'Content-Type' => 'application/octet-stream'},
              :expects => 204,
              :method  => 'PUT',
              :path    => "images/#{image_id}/file"
            }
            request_hash[:request_block] = params[:request_block] if params[:request_block]
            request_hash[:body] = body if body
            request(request_hash).body
          ensure
            body.close if body.respond_to?(:close)
          end
        end

        class Mock
          def upload_image(_image_id, _body)
            response = Excon::Response.new
            response.status = 204
          end
        end
      end
    end
  end
end
