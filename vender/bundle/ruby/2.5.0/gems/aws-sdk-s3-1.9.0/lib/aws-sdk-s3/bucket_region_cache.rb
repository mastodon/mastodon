require 'thread'

module Aws
  module S3
    class BucketRegionCache

      def initialize
        @regions = {}
        @listeners = []
        @mutex = Mutex.new
      end

      # Registers a block as a callback. This listener is called when a
      # new bucket/region pair is added to the cache.
      #
      #     S3::BUCKET_REGIONS.bucket_added do |bucket_name, region_name|
      #       # ...
      #     end
      #
      # This happens when a request is made against the classic endpoint,
      # "s3.amazonaws.com" and an error is returned requiring the request
      # to be resent with Signature Version 4. At this point, multiple
      # requests are made to discover the bucket region so that a v4
      # signature can be generated.
      #
      # An application can register listeners here to avoid these extra
      # requests in the future. By constructing an {S3::Client} with
      # the proper region, a proper signature can be generated and redirects
      # avoided.
      # @return [void]
      def bucket_added(&block)
        if block
          @mutex.synchronize { @listeners << block }
        else
          raise ArgumentError, 'missing required block'
        end
      end

      # @param [String] bucket_name
      # @return [String,nil] Returns the cached region for the named bucket.
      #   Returns `nil` if the bucket is not in the cache.
      # @api private
      def [](bucket_name)
        @mutex.synchronize { @regions[bucket_name] }
      end

      # Caches a bucket's region. Calling this method will trigger each
      # of the {#bucket_added} listener callbacks.
      # @param [String] bucket_name
      # @param [String] region_name
      # @return [void]
      # @api private
      def []=(bucket_name, region_name)
        @mutex.synchronize do
          @regions[bucket_name] = region_name
          @listeners.each { |block| block.call(bucket_name, region_name) }
        end
      end

      # @api private
      def clear
        @mutex.synchronize { @regions = {} }
      end

      # @return [Hash] Returns a hash of cached bucket names and region names.
      def to_hash
        @mutex.synchronize do
          @regions.dup
        end
      end
      alias to_h to_hash

    end

    # @api private
    BUCKET_REGIONS = BucketRegionCache.new

  end
end
