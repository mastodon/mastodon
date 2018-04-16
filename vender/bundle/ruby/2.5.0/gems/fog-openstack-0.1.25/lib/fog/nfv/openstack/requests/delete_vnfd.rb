module Fog
  module NFV
    class OpenStack
      class Real
        def delete_vnfd(vnfd_id)
          request(
            :expects => 204,
            :method  => "DELETE",
            :path    => "vnfds/#{vnfd_id}"
          )
        end
      end

      class Mock
        def delete_vnfd(_vnfd_id)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end
