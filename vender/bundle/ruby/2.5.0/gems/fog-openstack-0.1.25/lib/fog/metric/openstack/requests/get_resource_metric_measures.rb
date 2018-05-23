module Fog
  module Metric
    class OpenStack
      class Real
        def get_resource_metric_measures(resource_id, metric_name, options = {})
          request(
              :expects => 200,
              :method  => 'GET',
              :path    => "resource/generic/#{resource_id}/metric/#{metric_name}/measures",
              :query   => options
          )
        end
      end

      class Mock
        def get_resource_metric_measures(_resource_id, _metric_name, _options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [
              [
                  "2014-10-06T14:00:00+00:00",
                  3600.0,
                  24.7
              ],
              [
                  "2014-10-06T14:34:00+00:00",
                  60.0,
                  15.5
              ],
              [
                  "2014-10-06T14:34:12+00:00",
                  1.0,
                  6.0
              ],
              [
                  "2014-10-06T14:34:20+00:00",
                  1.0,
                  25.0
              ]
          ]
          response
        end
      end
    end
  end
end
