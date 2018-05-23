module Fog
  module Storage
    class OpenStack
      class Real
        # Get an expiring object http url
        #
        # ==== Parameters
        # * container<~String> - Name of container containing object
        # * object<~String> - Name of object to get expiring url for
        # * expires<~Time> - An expiry time for this url
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - url for object
        def get_object_http_url(container, object, expires, options = {})
          create_temp_url(container, object, expires, "GET", {:port => 80}.merge(options).merge(:scheme => "http"))
        end
      end
    end
  end
end
