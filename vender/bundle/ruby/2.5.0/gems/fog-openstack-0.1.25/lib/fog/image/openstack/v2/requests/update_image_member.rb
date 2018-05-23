module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def update_image_member(image_id, member)
            request( # 'status' is the only property we can update
              :body    => Fog::JSON.encode(member.select { |key, _value| key == 'status' }),
              :expects => [200],
              :method  => 'PUT',
              :path    => "images/#{image_id}/members/#{member['member_id']}"
            )
          end
        end # class Real

        class Mock
          def update_image_members(image_id, member)
            response = Excon::Response.new
            response.status = 204
            response.body = {
              :status     => "accepted",
              :created_at => "2013-11-26T07:21:21Z",
              :updated_at => "2013-11-26T07:21:21Z",
              :image_id   => image_id,
              :member_id  => member['member_id'],
              :schema     => "/v2/schemas/member"
            }
            response
          end
        end # class Mock
      end # class OpenStack
    end
  end # module Identity
end # module Fog
