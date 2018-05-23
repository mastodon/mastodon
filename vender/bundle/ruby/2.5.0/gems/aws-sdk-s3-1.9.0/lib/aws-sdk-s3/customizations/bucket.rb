require 'uri'

module Aws
  module S3
    class Bucket

      # Deletes all objects and versioned objects from this bucket
      #
      # @example
      #
      #   bucket.clear!
      #
      # @return [void]
      def clear!
        object_versions.batch_delete!
      end

      # Deletes all objects and versioned objects from this bucket and
      # then deletes the bucket.
      #
      # @example
      #
      #   bucket.delete!
      #
      # @option options [Integer] :max_attempts (3) Maximum number of times to
      #   attempt to delete the empty bucket before raising
      #   `Aws::S3::Errors::BucketNotEmpty`.
      #
      # @option options [Float] :initial_wait (1.3) Seconds to wait before
      #   retrying the call to delete the bucket, exponentially increased for
      #   each attempt.
      #
      # @return [void]
      def delete! options = { }
        options = {
          initial_wait: 1.3,
          max_attempts: 3,
        }.merge(options)

        attempts = 0
        begin
          clear!
          delete
        rescue Errors::BucketNotEmpty
          attempts += 1
          if attempts >= options[:max_attempts]
            raise
          else
            Kernel.sleep(options[:initial_wait] ** attempts)
            retry
          end
        end
      end

      # Returns a public URL for this bucket.
      #
      #     bucket = s3.bucket('bucket-name')
      #     bucket.url
      #     #=> "https://bucket-name.s3.amazonaws.com"
      #
      # You can pass `virtual_host: true` to use the bucket name as the
      # host name.
      #
      #     bucket = s3.bucket('my.bucket.com', virtual_host: true)
      #     bucket.url
      #     #=> "http://my.bucket.com"
      #
      # @option options [Boolean] :virtual_host (false) When `true`,
      #   the bucket name will be used as the host name. This is useful
      #   when you have a CNAME configured for this bucket.
      #
      # @return [String] the URL for this bucket.
      def url(options = {})
        if options[:virtual_host]
          "http://#{name}"
        else
          s3_bucket_url
        end
      end

      # Creates a {PresignedPost} that makes it easy to upload a file from
      # a web browser direct to Amazon S3 using an HTML post form with
      # a file field.
      #
      # See the {PresignedPost} documentation for more information.
      # @note You must specify `:key` or `:key_starts_with`. All other options
      #   are optional.
      # @option (see PresignedPost#initialize)
      # @return [PresignedPost]
      # @see PresignedPost
      def presigned_post(options = {})
        PresignedPost.new(
          client.config.credentials,
          client.config.region,
          name,
          {url: url}.merge(options)
        )
      end

      # @api private
      def load
        @data = client.list_buckets.buckets.find { |b| b.name == name }
        raise "unable to load bucket #{name}" if @data.nil?
        self
      end

      private

      def s3_bucket_url
        url = client.config.endpoint.dup
        if bucket_as_hostname?(url.scheme == 'https')
          url.host = "#{name}.#{url.host}"
        else
          url.path += '/' unless url.path[-1] == '/'
          url.path += Seahorse::Util.uri_escape(name)
        end
        url.to_s
      end

      def bucket_as_hostname?(https)
        Plugins::BucketDns.dns_compatible?(name, https) &&
        !client.config.force_path_style
      end

    end
  end
end
