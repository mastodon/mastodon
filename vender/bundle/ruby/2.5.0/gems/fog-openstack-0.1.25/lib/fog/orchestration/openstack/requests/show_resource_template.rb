module Fog
  module Orchestration
    class OpenStack
      class Real
        def show_resource_template(name)
          request(
            :method  => 'GET',
            :path    => "resource_types/#{name}/template",
            :expects => 200
          )
        end
      end

      class Mock
        def show_resource_template(name)
        end
      end
    end
  end
end
