module Fog
  module NFV
    class OpenStack
      class Real
        def get_vnf(vnf_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "vnfs/#{vnf_id}"
          )
        end
      end

      class Mock
        def get_vnf(_vnf_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {"vnf" => data[:vnfs].first}
          response
        end
      end
    end
  end
end
