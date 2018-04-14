module Fog
  module Orchestration
    class OpenStack
      class Real
        def list_resource_types(_options = {})
          request(
            :method  => 'GET',
            :path    => "resource_types",
            :expects => 200,
            :query   => {}
          )
        end
      end

      class Mock
        def list_resource_types
          resources = data[:resource_types].values

          Excon::Response.new(
            :body   => {'resource_types' => resources},
            :status => 200
          )
        end
      end
    end
  end
end
