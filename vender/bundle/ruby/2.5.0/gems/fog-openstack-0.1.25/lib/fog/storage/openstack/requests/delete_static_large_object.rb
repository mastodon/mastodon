module Fog
  module Storage
    class OpenStack
      class Real
        # Delete a static large object.
        #
        # Deletes the SLO manifest +object+ and all segments that it references.
        # The server will respond with +200 OK+ for all requests.
        # +response.body+ must be inspected for actual results.
        #
        # @param container [String] Name of container.
        # @param object [String] Name of the SLO manifest object.
        # @param options [Hash] Additional request headers.
        #
        # @return [Excon::Response]
        #   * body [Hash] - Results of the operation.
        #     * "Number Not Found" [Integer] - Number of missing segments.
        #     * "Response Status" [String] - Response code for the subrequest of the last failed operation.
        #     * "Errors" [Array<object_name, response_status>]
        #       * object_name [String] - Object that generated an error when the delete was attempted.
        #       * response_status [String] - Response status from the subrequest for object_name.
        #     * "Number Deleted" [Integer] - Number of segments deleted.
        #     * "Response Body" [String] - Response body for Response Status.
        #
        # @see http://docs.openstack.org/api/openstack-object-storage/1.0/content/static-large-objects.html
        def delete_static_large_object(container, object, options = {})
          response = request({
                               :expects => 200,
                               :method  => 'DELETE',
                               :headers => options.merge('Content-Type' => 'text/plain',
                                                         'Accept'       => 'application/json'),
                               :path    => "#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object)}",
                               :query   => {'multipart-manifest' => 'delete'}
                             }, false)
          response.body = Fog::JSON.decode(response.body)
          response
        end
      end
    end
  end
end
