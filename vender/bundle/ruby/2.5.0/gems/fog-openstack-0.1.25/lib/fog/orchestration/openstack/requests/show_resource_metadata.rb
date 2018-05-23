module Fog
  module Orchestration
    class OpenStack
      class Real
        def show_resource_metadata(stack, resource_name)
          request(
            :method  => 'GET',
            :path    => "stacks/#{stack.stack_name}/#{stack.id}/resources/#{resource_name}/metadata",
            :expects => 200
          )
        end
      end

      class Mock
        def show_resource_metadata(_stack, _resource_name)
          resources = data[:resources].values

          Excon::Response.new(
            :body   => {'resources' => resources},
            :status => 200
          )
        end
      end
    end
  end
end
