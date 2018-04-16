module Fog
  module Storage
    class OpenStack
      class Real
        # Get details for container and total bytes stored
        #
        # ==== Parameters
        # * container<~String> - Name of container to retrieve info for
        # * options<~String>:
        #   * 'limit'<~String> - Maximum number of objects to return
        #   * 'marker'<~String> - Only return objects whose name is greater than marker
        #   * 'prefix'<~String> - Limits results to those starting with prefix
        #   * 'path'<~String> - Return objects nested in the pseudo path
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * headers<~Hash>:
        #     * 'X-Account-Container-Count'<~String> - Count of containers
        #     * 'X-Account-Bytes-Used'<~String> - Bytes used
        #   * body<~Array>:
        #     * 'bytes'<~Integer> - Number of bytes used by container
        #     * 'count'<~Integer> - Number of items in container
        #     * 'name'<~String> - Name of container
        #     * item<~Hash>:
        #       * 'bytes'<~String> - Size of object
        #       * 'content_type'<~String> Content-Type of object
        #       * 'hash'<~String> - Hash of object (etag?)
        #       * 'last_modified'<~String> - Last modified timestamp
        #       * 'name'<~String> - Name of object
        def get_container(container, options = {})
          options = options.reject { |_key, value| value.nil? }
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => Fog::OpenStack.escape(container),
            :query   => {'format' => 'json'}.merge!(options)
          )
        end
      end
    end
  end
end
