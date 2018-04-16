module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def delete_cluster_template(uuid_or_name)
          request(
            :expects => [204],
            :method  => 'DELETE',
            :path    => "clustertemplates/#{uuid_or_name}"
          )
        end
      end

      class Mock
        def delete_cluster_template(_uuid_or_name)
          response = Excon::Response.new
          response.status = 204
          response.body = {}
          response
        end
      end
    end
  end
end
