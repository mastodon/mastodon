module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def delete_cluster(uuid_or_name)
          request(
            :expects => [204],
            :method  => 'DELETE',
            :path    => "clusters/#{uuid_or_name}"
          )
        end
      end

      class Mock
        def delete_cluster(_uuid_or_name)
          response = Excon::Response.new
          response.status = 204
          response.body = {}
          response
        end
      end
    end
  end
end
