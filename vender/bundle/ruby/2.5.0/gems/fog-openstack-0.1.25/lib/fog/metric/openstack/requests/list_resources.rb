module Fog
  module Metric
    class OpenStack
      class Real
        def list_resources(type = "generic", options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "resource/#{Fog::OpenStack.escape(type)}",
            :query   => options
          )
        end
      end

      class Mock
        def list_resources(_type = "generic", _options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [
              {
                  "created_by_project_id" => "384a902b-6856-424c-9d30-6b5325ac20a5",
                  "created_by_user_id"    => "d040def9-fd68-45f0-a19f-253014f397c3",
                  "ended_at"              => nil,
                  "id"                    => "75c44741-cc60-4033-804e-2d3098c7d2e9",
                  "metrics"               => {},
                  "original_resource_id"  => "75C44741-CC60-4033-804E-2D3098C7D2E9",
                  "project_id"            => "BD3A1E52-1C62-44CB-BF04-660BD88CD74D",
                  "revision_end"          => nil,
                  "revision_start"        => "2016-11-08T11:23:45.989977+00:00",
                  "started_at"            => "2016-11-08T11:23:45.989960+00:00",
                  "type"                  => "generic",
                  "user_id"               => "BD3A1E52-1C62-44CB-BF04-660BD88CD74D"
              },
              {
                  "created_by_project_id" => "384a902b-6856-424c-9d30-6b5325ac20a5",
                  "created_by_user_id"    => "d040def9-fd68-45f0-a19f-253014f397c3",
                  "ended_at"              => nil,
                  "id"                    => "ab68da77-fa82-4e67-aba9-270c5a98cbcb",
                  "metrics" => {
                      "temperature" => "ed51c966-8890-4f4e-96c4-f0a753dbad42"
                  },
                  "original_resource_id" => "AB68DA77-FA82-4E67-ABA9-270C5A98CBCB",
                  "project_id"           => "BD3A1E52-1C62-44CB-BF04-660BD88CD74D",
                  "revision_end"         => nil,
                  "revision_start"       => "2016-11-08T11:23:46.177259+00:00",
                  "started_at"           => "2016-11-08T11:23:46.177236+00:00",
                  "type"                 => "generic",
                  "user_id"              => "BD3A1E52-1C62-44CB-BF04-660BD88CD74D"
              },
              {
                  "created_by_project_id" => "384a902b-6856-424c-9d30-6b5325ac20a5",
                  "created_by_user_id"    => "d040def9-fd68-45f0-a19f-253014f397c3",
                  "ended_at"              => "2014-01-04T10:00:12+00:00",
                  "id"                    => "6868da77-fa82-4e67-aba9-270c5ae8cbca",
                  "metrics"               => {},
                  "original_resource_id"  => "6868DA77-FA82-4E67-ABA9-270C5AE8CBCA",
                  "project_id"            => "BD3A1E52-1C62-44CB-BF04-660BD88CD74D",
                  "revision_end"          => nil,
                  "revision_start"        => "2016-11-08T11:23:46.781604+00:00",
                  "started_at"            => "2014-01-02T23:23:34+00:00",
                  "type"                  => "instance",
                  "user_id"               => "BD3A1E52-1C62-44CB-BF04-660BD88CD74D"
              }
          ]
          response
        end
      end
    end
  end
end
