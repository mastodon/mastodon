module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_metric_names(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "metrics/names",
            :query   => options
          )
        end
      end

      class Mock
        # def list_metrics(options = {})
        #
        # end
      end
    end
  end
end
