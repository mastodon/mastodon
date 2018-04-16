module Fog
  module Storage
    class OpenStack
      class Real
        # Create a new static large object manifest.
        #
        # A static large object is similar to a dynamic large object. Whereas a GET for a dynamic large object manifest
        # will stream segments based on the manifest's +X-Object-Manifest+ object name prefix, a static large object
        # manifest streams segments which are defined by the user within the manifest. Information about each segment is
        # provided in +segments+ as an Array of Hash objects, ordered in the sequence which the segments should be streamed.
        #
        # When the SLO manifest is received, each segment's +etag+ and +size_bytes+ will be verified.
        # The +etag+ for each segment is returned in the response to {#put_object}, but may also be calculated.
        # e.g. +Digest::MD5.hexdigest(segment_data)+
        #
        # The maximum number of segments for a static large object is 1000, and all segments (except the last) must be
        # at least 1 MiB in size. Unlike a dynamic large object, segments are not required to be in the same container.
        #
        # @example
        #   segments = [
        #     { :path => 'segments_container/first_segment',
        #       :etag => 'md5 for first_segment',
        #       :size_bytes => 'byte size of first_segment' },
        #     { :path => 'segments_container/second_segment',
        #       :etag => 'md5 for second_segment',
        #       :size_bytes => 'byte size of second_segment' }
        #   ]
        #   put_static_obj_manifest('my_container', 'my_large_object', segments)
        #
        # @param container [String] Name for container where +object+ will be stored.
        #     Should be < 256 bytes and must not contain '/'
        # @param object [String] Name for manifest object.
        # @param segments [Array<Hash>] Segment data for the object.
        # @param options [Hash] Config headers for +object+.
        #
        # @raise [Fog::Storage::OpenStack::NotFound] HTTP 404
        # @raise [Excon::Errors::BadRequest] HTTP 400
        # @raise [Excon::Errors::Unauthorized] HTTP 401
        # @raise [Excon::Errors::HTTPStatusError]
        #
        # @see http://docs.openstack.org/api/openstack-object-storage/1.0/content/static-large-objects.html
        def put_static_obj_manifest(container, object, segments, options = {})
          request(
            :expects => 201,
            :method  => 'PUT',
            :headers => options,
            :body    => Fog::JSON.encode(segments),
            :path    => "#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object)}",
            :query   => {'multipart-manifest' => 'put'}
          )
        end
      end
    end
  end
end
