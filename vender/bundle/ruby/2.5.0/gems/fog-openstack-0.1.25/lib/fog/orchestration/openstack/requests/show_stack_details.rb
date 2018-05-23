module Fog
  module Orchestration
    class OpenStack
      class Real
        def show_stack_details(name, id)
          request(
            :method  => 'GET',
            :path    => "stacks/#{name}/#{id}",
            :expects => 200
          )
        end
      end

      class Mock
        def show_stack_details(_name, _id)
          stack = data[:stack].values

          Excon::Response.new(
            :body   => {'stack' => stack},
            :status => 200
          )
        end
      end
    end
  end
end
