module Fog
  module Storage
    class OpenStack
      class Real
        # List existing storage containers
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'limit'<~Integer> - Upper limit to number of results returned
        #   * 'marker'<~String> - Only return objects with name greater than this value
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * container<~Hash>:
        #       * 'bytes'<~Integer>: - Number of bytes used by container
        #       * 'count'<~Integer>: - Number of items in container
        #       * 'name'<~String>: - Name of container
        def get_containers(options = {})
          options = options.reject { |_key, value| value.nil? }
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => '',
            :query   => {'format' => 'json'}.merge!(options)
          )
        end
      end
    end
  end
end
