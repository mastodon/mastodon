module Fog
  module NFV
    class OpenStack
      class Real
        def get_vnfd(vnfd_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "vnfds/#{vnfd_id}"
          )
        end
      end

      class Mock
        def get_vnfd(_vnfd_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {"vnfd" => data[:vnfds].first}
          response
        end
      end
    end
  end
end
