module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_statistics(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "metrics/statistics",
            :query   => options
          )
        end
      end

      class Mock
        # def list_statistics(options = {})
        #
        # end
      end
    end
  end
end
