module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def get_role(id)
            request(
              :expects => [200, 204],
              :method  => 'GET',
              :path    => "/OS-KSADM/roles/#{id}"
            )
          end
        end

        class Mock
          def get_role(id)
            response = Excon::Response.new
            if data = self.data[:roles][id]
              response.status = 200
              response.body = {'role' => data}
              response
            else
              raise Fog::Identity::OpenStack::NotFound
            end
          end
        end # class Mock
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog
