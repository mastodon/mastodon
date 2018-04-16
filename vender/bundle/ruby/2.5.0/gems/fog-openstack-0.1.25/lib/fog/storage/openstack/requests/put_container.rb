module Fog
  module Storage
    class OpenStack
      class Real
        # Create a new container
        #
        # ==== Parameters
        # * name<~String> - Name for container, should be < 256 bytes and must not contain '/'
        #
        def put_container(name, options = {})
          headers = options[:headers] || {}
          headers['X-Container-Read'] = '.r:*' if options[:public]
          headers['X-Remove-Container-Read'] = 'x' if options[:public] == false
          request(
            :expects => [201, 202],
            :method  => 'PUT',
            :path    => Fog::OpenStack.escape(name),
            :headers => headers
          )
        end
      end
    end
  end
end
