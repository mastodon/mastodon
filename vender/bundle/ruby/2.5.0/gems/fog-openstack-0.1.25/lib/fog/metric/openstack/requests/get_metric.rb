module Fog
  module Metric
    class OpenStack
      class Real
        def get_metric(metric_id)
          request(
              :expects => 200,
              :method  => 'GET',
              :path    => "metric/#{metric_id}"
          )
        end
      end

      class Mock
        def get_metric(_metric_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
              "archive_policy" => {
                  "aggregation_methods" => [
                      "95pct",
                      "median",
                      "max",
                      "count",
                      "std",
                      "sum",
                      "min",
                      "mean"
                  ],
                  "back_window" => 0,
                  "definition"  => [
                      {
                          "granularity" => "0:00:01",
                          "points"      => 3600,
                          "timespan"    => "1:00:00"
                      },
                      {
                          "granularity" => "0:01:00",
                          "points"      => 10080,
                          "timespan"    => "7 days, 0:00:00"
                      },
                      {
                          "granularity" => "1:00:00",
                          "points"      => 8760,
                          "timespan"    => "365 days, 0:00:00"
                      }
                  ],
                  "name" => "high"
              },
              "created_by_project_id" => "384a902b-6856-424c-9d30-6b5325ac20a5",
              "created_by_user_id"    => "d040def9-fd68-45f0-a19f-253014f397c3",
              "id"                    => "8bbb5f02-b654-4861-b19e-d372fcdca124",
              "name"     => nil,
              "resource" => nil,
              "unit"     => nil
          }
          response
        end
      end
    end
  end
end
