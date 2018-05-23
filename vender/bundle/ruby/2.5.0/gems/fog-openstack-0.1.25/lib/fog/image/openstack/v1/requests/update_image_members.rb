module Fog
  module Image
    class OpenStack
      class V1
        class Real
          def update_image_members(image_id, members)
            # Sample members
            # [
            #   {'member_id' => 'tenant1', 'can_share' => true  },
            #   {'member_id' => 'tenant2', 'can_share' => false }
            # ]
            data = {'memberships' => members}

            request(
              :body    => Fog::JSON.encode(data),
              :expects => [204],
              :method  => 'PUT',
              :path    => "images/#{image_id}/members"
            )
          end
        end # class Real

        class Mock
          def update_image_members(_image_id, _members)
            response = Excon::Response.new
            response.status = 204
            response.body = {
              'members' => [
                {'member_id' => 'ff528b20431645ebb5fa4b0a71ca002f', 'can_share' => false},
                {'member_id' => 'ff528b20431645ebb5fa4b0a71ca002f', 'can_share' => true}
              ]
            }
            response
          end
        end # class Mock
      end # class OpenStack
    end
  end # module Identity
end # module Fog
