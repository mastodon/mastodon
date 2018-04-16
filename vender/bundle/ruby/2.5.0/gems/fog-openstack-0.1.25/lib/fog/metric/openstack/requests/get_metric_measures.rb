module Fog
  module Metric
    class OpenStack
      class Real
        def get_metric_measures(metric_id, options = {})
          request(
              :expects => 200,
              :method  => 'GET',
              :path    => "metric/#{metric_id}/measures",
              :query    => options,
          )
        end
      end

      class Mock
        def get_metric_measures(_metric_id, _options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [
              {
                  "timestamp" => "2014-10-06T14:33:57",
                  "value"     => 43.1
              },
              {
                  "timestamp" => "2014-10-06T14:34:12",
                  "value"     => 12
              },
              {
                  "timestamp" => "2014-10-06T14:34:20",
                  "value"     => 2
              }
          ]
          response
        end
      end
    end
  end
end
