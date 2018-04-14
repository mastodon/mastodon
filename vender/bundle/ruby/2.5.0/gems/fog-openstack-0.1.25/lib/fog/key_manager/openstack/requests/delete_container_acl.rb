module Fog
  module KeyManager
    class OpenStack
      class Real
        def delete_container_acl(uuid)
          request(
            :expects => [200],
            :method  => 'DELETE',
            :path    => "containers/#{uuid}/acl"
          )
        end
      end

      class Mock
        def delete_container_acl(_uuid)
          response = Excon::Response.new
          response.status = 200
          response.body = "null"
          response
        end
      end
    end
  end
end
