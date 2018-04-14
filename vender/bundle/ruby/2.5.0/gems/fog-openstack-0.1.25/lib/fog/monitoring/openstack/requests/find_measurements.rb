module Fog
  module Monitoring
    class OpenStack
      class Real
        def find_measurements(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "metrics/measurements",
            :query   => options
          )
        end
      end

      class Mock
        # def list_measurements(options = {})
        #
        # end
      end
    end
  end
end
