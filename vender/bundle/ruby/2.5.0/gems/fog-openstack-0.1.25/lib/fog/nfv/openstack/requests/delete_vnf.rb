module Fog
  module NFV
    class OpenStack
      class Real
        def delete_vnf(vnf_id)
          request(
            :expects => 204,
            :method  => "DELETE",
            :path    => "vnfs/#{vnf_id}"
          )
        end
      end

      class Mock
        def delete_vnf(_vnf_id)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end
