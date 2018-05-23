module Fog
  module Storage
    class OpenStack
      class Real
        # Get headers for object
        #
        # ==== Parameters
        # * container<~String> - Name of container to look in
        # * object<~String> - Name of object to look for
        #
        def head_object(container, object)
          request({
                    :expects => 200,
                    :method  => 'HEAD',
                    :path    => "#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object)}"
                  }, false)
        end
      end
    end
  end
end
