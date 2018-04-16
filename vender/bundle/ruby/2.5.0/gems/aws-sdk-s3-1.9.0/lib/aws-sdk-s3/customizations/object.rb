module Aws
  module S3
    class Object

      alias size content_length

      # Copies another object to this object. Use `multipart_copy: true`
      # for large objects. This is required for objects that exceed 5GB.
      #
      # @param [S3::Object, S3::ObjectVersion, S3::ObjectSummary, String, Hash] source
      #   Where to copy object data from. `source` must be one of the following:
      #
      #   * {Aws::S3::Object}
      #   * {Aws::S3::ObjectSummary}
      #   * {Aws::S3::ObjectVersion}
      #   * Hash - with `:bucket` and `:key` and optional `:version_id`
      #   * String - formatted like `"source-bucket-name/uri-escaped-key"`
      #     or `"source-bucket-name/uri-escaped-key?versionId=version-id"`
      #
      # @option options [Boolean] :multipart_copy (false) When `true`,
      #   the object will be copied using the multipart APIs. This is
      #   necessary for objects larger than 5GB and can provide
      #   performance improvements on large objects. Amazon S3 does
      #   not accept multipart copies for objects smaller than 5MB.
      #
      # @option options [Integer] :content_length Only used when
      #   `:multipart_copy` is `true`. Passing this options avoids a HEAD
      #   request to query the source object size.
      #
      # @option options [S3::Client] :copy_source_client Only used when
      #   `:multipart_copy` is `true` and the source object is in a
      #   different region. You do not need to specify this option
      #   if you have provided `:content_length`.
      #
      # @option options [String] :copy_source_region Only used when
      #   `:multipart_copy` is `true` and the source object is in a
      #   different region. You do not need to specify this option
      #   if you have provided a `:source_client` or a `:content_length`.
      #
      # @example Basic object copy
      #
      #   bucket = Aws::S3::Bucket.new('target-bucket')
      #   object = bucket.object('target-key')
      #
      #   # source as String
      #   object.copy_from('source-bucket/source-key')
      #
      #   # source as Hash
      #   object.copy_from(bucket:'source-bucket', key:'source-key')
      #
      #   # source as Aws::S3::Object
      #   object.copy_from(bucket.object('source-key'))
      #
      # @example Managed copy of large objects
      #
      #   # uses multipart upload APIs to copy object
      #   object.copy_from('src-bucket/src-key', multipart_copy: true)
      #
      # @see #copy_to
      #
      def copy_from(source, options = {})
        if Hash === source && source[:copy_source]
          # for backwards compatibility
          @client.copy_object(source.merge(bucket: bucket_name, key: key))
        else
          ObjectCopier.new(self, options).copy_from(source, options)
        end
      end

      # Copies this object to another object. Use `multipart_copy: true`
      # for large objects. This is required for objects that exceed 5GB.
      #
      # @note If you need to copy to a bucket in a different region, use
      #   {#copy_from}.
      #
      # @param [S3::Object, String, Hash] target Where to copy the object
      #   data to. `target` must be one of the following:
      #
      #   * {Aws::S3::Object}
      #   * Hash - with `:bucket` and `:key`
      #   * String - formatted like `"target-bucket-name/target-key"`
      #
      # @example Basic object copy
      #
      #   bucket = Aws::S3::Bucket.new('source-bucket')
      #   object = bucket.object('source-key')
      #
      #   # target as String
      #   object.copy_to('target-bucket/target-key')
      #
      #   # target as Hash
      #   object.copy_to(bucket: 'target-bucket', key: 'target-key')
      #
      #   # target as Aws::S3::Object
      #   object.copy_to(bucket.object('target-key'))
      #
      # @example Managed copy of large objects
      #
      #   # uses multipart upload APIs to copy object
      #   object.copy_to('src-bucket/src-key', multipart_copy: true)
      #
      def copy_to(target, options = {})
        ObjectCopier.new(self, options).copy_to(target, options)
      end

      # Copies and deletes the current object. The object will only be
      # deleted if the copy operation succeeds.
      # @param (see Object#copy_to)
      # @option (see Object#copy_to)
      # @return [void]
      # @see Object#copy_to
      # @see Object#delete
      def move_to(target, options = {})
        copy_to(target, options)
        delete
      end

      # Creates a {PresignedPost} that makes it easy to upload a file from
      # a web browser direct to Amazon S3 using an HTML post form with
      # a file field.
      #
      # See the {PresignedPost} documentation for more information.
      #
      # @option (see PresignedPost#initialize)
      # @return [PresignedPost]
      # @see PresignedPost
      def presigned_post(options = {})
        PresignedPost.new(
          client.config.credentials,
          client.config.region,
          bucket_name,
          {
            key: key,
            url: bucket.url,
          }.merge(options)
        )
      end

      # Generates a pre-signed URL for this object.
      #
      # @example Pre-signed GET URL, valid for one hour
      #
      #     obj.presigned_url(:get, expires_in: 3600)
      #     #=> "https://bucket-name.s3.amazonaws.com/object-key?..."
      #
      # @example Pre-signed PUT with a canned ACL
      #
      #     # the object uploaded using this URL will be publicly accessible
      #     obj.presigned_url(:put, acl: 'public-read')
      #     #=> "https://bucket-name.s3.amazonaws.com/object-key?..."
      #
      # @param [Symbol] http_method
      #   The HTTP method to generate a presigned URL for. Valid values
      #   are `:get`, `:put`, `:head`, and `:delete`.
      #
      # @param [Hash] params
      #   Additional request parameters to use when generating the pre-signed
      #   URL. See the related documentation in {Client} for accepted
      #   params.
      #
      #   | HTTP Method   | Client Method          |
      #   |---------------|------------------------|
      #   | `:get`        | {Client#get_object}    |
      #   | `:put`        | {Client#put_object}    |
      #   | `:head`       | {Client#head_object}   |
      #   | `:delete`     | {Client#delete_object} |
      #
      # @option params [Boolean] :virtual_host (false) When `true` the
      #   presigned URL will use the bucket name as a virtual host.
      #
      #     bucket = Aws::S3::Bucket.new('my.bucket.com')
      #     bucket.object('key').presigned_url(virtual_host: true)
      #     #=> "http://my.bucket.com/key?..."
      #
      # @option params [Integer] :expires_in (900) Number of seconds before
      #   the pre-signed URL expires. This may not exceed one week (604800
      #   seconds). Note that the pre-signed URL is also only valid as long as
      #   credentials used to sign it are. For example, when using IAM roles,
      #   temporary tokens generated for signing also have a default expiration
      #   which will affect the effective expiration of the pre-signed URL.
      #
      # @raise [ArgumentError] Raised if `:expires_in` exceeds one week
      #   (604800 seconds).
      #
      # @return [String]
      #
      def presigned_url(http_method, params = {})
        presigner = Presigner.new(client: client)
        presigner.presigned_url("#{http_method.downcase}_object", params.merge(
          bucket: bucket_name,
          key: key,
        ))
      end

      # Returns the public (un-signed) URL for this object.
      #
      #     s3.bucket('bucket-name').object('obj-key').public_url
      #     #=> "https://bucket-name.s3.amazonaws.com/obj-key"
      #
      # To use virtual hosted bucket url (disables https):
      #
      #     s3.bucket('my.bucket.com').object('key').public_url(virtual_host: true)
      #     #=> "http://my.bucket.com/key"
      #
      # @option options [Boolean] :virtual_host (false) When `true`, the bucket
      #   name will be used as the host name. This is useful when you have
      #   a CNAME configured for the bucket.
      #
      # @return [String]
      def public_url(options = {})
        url = URI.parse(bucket.url(options))
        url.path += '/' unless url.path[-1] == '/'
        url.path += key.gsub(/[^\/]+/) { |s| Seahorse::Util.uri_escape(s) }
        url.to_s
      end

      # Uploads a file from disk to the current object in S3.
      #
      #     # small files are uploaded in a single API call
      #     obj.upload_file('/path/to/file')
      #
      # Files larger than `:multipart_threshold` are uploaded using the
      # Amazon S3 multipart upload APIs.
      #
      #     # large files are automatically split into parts
      #     # and the parts are uploaded in parallel
      #     obj.upload_file('/path/to/very_large_file')
      #
      # @param [String,Pathname,File,Tempfile] source A file or path to a file
      #   on the local file system that should be uploaded to this object.
      #   If you pass an open file object, then it is your responsibility
      #   to close the file object once the upload completes.
      #
      # @option options [Integer] :multipart_threshold (15728640) Files larger
      #   than `:multipart_threshold` are uploaded using the S3 multipart APIs.
      #   Default threshold is 15MB.
      #
      # @raise [MultipartUploadError] If an object is being uploaded in
      #   parts, and the upload can not be completed, then the upload is
      #   aborted and this error is raised.  The raised error has a `#errors`
      #   method that returns the failures that caused the upload to be
      #   aborted.
      #
      # @return [Boolean] Returns `true` when the object is uploaded
      #   without any errors.
      #
      def upload_file(source, options = {})
        uploading_options = options.dup
        uploader = FileUploader.new(
          multipart_threshold: uploading_options.delete(:multipart_threshold),
          client: client)
        uploader.upload(source, uploading_options.merge(bucket: bucket_name, key: key))
        true
      end

      # Downloads a file in S3 to a path on disk.
      #
      #     # small files (< 5MB) are downloaded in a single API call
      #     obj.download_file('/path/to/file')
      #
      # Files larger than 5MB are downloaded using multipart method
      #
      #     # large files are split into parts
      #     # and the parts are downloaded in parallel
      #     obj.download_file('/path/to/very_large_file')
      #
      # @param [String] destination Where to download the file to
      #
      # @option options [String] mode `auto`, `single_request`, `get_range`
      #  `single_request` mode forces only 1 GET request is made in download,
      #  `get_range` mode allows `chunk_size` parameter to configured in
      #  customizing each range size in multipart_download,
      #  By default, `auto` mode is enabled, which performs multipart_download
      #
      # @option options [String] chunk_size required in get_range mode
      #
      # @option options [String] thread_count Customize threads used in multipart
      #   download, if not provided, 10 is default value
      #
      # @return [Boolean] Returns `true` when the file is downloaded
      #   without any errors.
      def download_file(destination, options = {})
        downloader = FileDownloader.new(client: client)
        downloader.download(
          destination, options.merge(bucket: bucket_name, key: key))
        true
      end
    end
  end
end
