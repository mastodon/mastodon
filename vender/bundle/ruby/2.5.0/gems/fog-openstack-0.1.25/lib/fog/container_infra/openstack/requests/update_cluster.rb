module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def update_cluster(uuid_or_name, params)
          request(
            :expects => [202, 200],
            :method  => 'PATCH',
            :path    => "clusters/#{uuid_or_name}",
            :body    => Fog::JSON.encode(params)
          )
        end
      end

      class Mock
        def update_cluster(_uuid_or_name, _params)
          response = Excon::Response.new
          response.status = 202
          response.body = {
            "uuid" => "746e779a-751a-456b-a3e9-c883d734946f"
          }
          response
        end
      end
    end
  end
end
