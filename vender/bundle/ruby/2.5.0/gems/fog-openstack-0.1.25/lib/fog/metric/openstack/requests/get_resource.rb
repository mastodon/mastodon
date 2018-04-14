module Fog
  module Metric
    class OpenStack
      class Real
        def get_resource(resource_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "resource/generic/#{resource_id}"
          )
        end
      end

      class Mock
        def get_resource(_resource_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
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
          }
          response
        end
      end
    end
  end
end
