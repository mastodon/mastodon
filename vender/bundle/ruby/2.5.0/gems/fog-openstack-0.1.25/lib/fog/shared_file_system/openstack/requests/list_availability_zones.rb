module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_availability_zones()
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => microversion_newer_than?('2.6') ? 'availability-zones' : 'os-availability-zone'
          )
        end
      end

      class Mock
        def list_availability_zones()
          response = Excon::Response.new
          response.status = 200
          response.body = {'availability_zones' => data[:availability_zones]}
          response
        end
      end
    end
  end
end
