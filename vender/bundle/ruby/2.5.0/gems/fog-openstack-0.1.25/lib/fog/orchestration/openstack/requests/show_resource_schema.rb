module Fog
  module Orchestration
    class OpenStack
      class Real
        def show_resource_schema(name)
          request(
            :method  => 'GET',
            :path    => "resource_types/#{name}",
            :expects => 200
          )
        end
      end
    end
  end
end
