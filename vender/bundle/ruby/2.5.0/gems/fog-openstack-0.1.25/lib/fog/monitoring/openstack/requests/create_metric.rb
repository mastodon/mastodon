module Fog
  module Monitoring
    class OpenStack
      class Real
        def create_metric(options)
          data = options
          # data = {
          #         'name' => name,
          #         'dimensions' => dimensions,
          #         'timestamp' => timestamp,
          #         'value' => value,
          #         'value_meta' => value_meta
          # }

          # _create_metric(data)
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [204],
            :method  => 'POST',
            :path    => 'metrics'
          )
        end
      end

      class Mock
      end
    end
  end
end
