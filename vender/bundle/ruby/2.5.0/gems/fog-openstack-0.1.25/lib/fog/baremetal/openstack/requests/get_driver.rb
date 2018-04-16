module Fog
  module Baremetal
    class OpenStack
      class Real
        def get_driver(driver_name)
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => "drivers/#{driver_name}"
          )
        end
      end # class Real

      class Mock
        def get_driver(_driver_name)
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = data[:drivers].first
          response
        end # def get_driver
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
