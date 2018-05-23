module Fog
  module Metric
    class OpenStack
      class Real
        def list_metrics(options = {})
          request(
              :expects => 200,
              :method  => 'GET',
              :path    => 'metric',
              :query   => options
          )
        end
      end

      class Mock
        def list_metrics(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [
              {
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
                  "name"                  => nil,
                  "resource_id"           => nil,
                  "unit"                  => nil
              },
              {
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
                      "definition" => [
                          {
                              "granularity" => "0:05:00",
                              "points"      => 12,
                              "timespan"    => "1:00:00"
                          },
                          {
                              "granularity" => "1:00:00",
                              "points"      => 24,
                              "timespan"    => "1 day, 0:00:00"
                          },
                          {
                              "granularity" => "1 day, 0:00:00",
                              "points"      => 30,
                              "timespan"    => "30 days, 0:00:00"
                          }
                      ],
                      "name" => "low"
                  },
                  "created_by_project_id" => "384a902b-6856-424c-9d30-6b5325ac20a5",
                  "created_by_user_id"    => "d040def9-fd68-45f0-a19f-253014f397c3",
                  "id"                    => "af3446dc-e20f-4ecf-aaaa-1240c05ff19b",
                  "name"                  => nil,
                  "resource_id"           => nil,
                  "unit"                  => nil
              }
          ]
          response
        end
      end
    end
  end
end
