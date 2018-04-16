module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def get_member_details(image_id, member_id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "images/#{image_id}/members/#{member_id}"
            ).body
          end
        end # class Real

        class Mock
          def get_member_details(_image_id, _member_id)
            response = Excon::Response.new
            response.status = 200
            response.body = {
              :status     => "pending",
              :created_at => "2013-11-26T07:21:21Z",
              :updated_at => "2013-11-26T07:21:21Z",
              :image_id   => "0ae74cc5-5147-4239-9ce2-b0c580f7067e",
              :member_id  => "8989447062e04a818baf9e073fd04fa7",
              :schema     => "/v2/schemas/member"
            }
            response
          end # def list_tenants
        end # class Mock
      end # class OpenStack
    end
  end # module Identity
end # module Fog
