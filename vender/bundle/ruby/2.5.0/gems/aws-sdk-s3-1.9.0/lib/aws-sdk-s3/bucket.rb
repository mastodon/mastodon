# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::S3
  class Bucket

    extend Aws::Deprecations

    # @overload def initialize(name, options = {})
    #   @param [String] name
    #   @option options [Client] :client
    # @overload def initialize(options = {})
    #   @option options [required, String] :name
    #   @option options [Client] :client
    def initialize(*args)
      options = Hash === args.last ? args.pop.dup : {}
      @name = extract_name(args, options)
      @data = options.delete(:data)
      @client = options.delete(:client) || Client.new(options)
    end

    # @!group Read-Only Attributes

    # @return [String]
    def name
      @name
    end

    # Date the bucket was created.
    # @return [Time]
    def creation_date
      data[:creation_date]
    end

    # @!endgroup

    # @return [Client]
    def client
      @client
    end

    # @raise [NotImplementedError]
    # @api private
    def load
      msg = "#load is not implemented, data only available via enumeration"
      raise NotImplementedError, msg
    end
    alias :reload :load

    # @raise [NotImplementedError] Raises when {#data_loaded?} is `false`.
    # @return [Types::Bucket]
    #   Returns the data for this {Bucket}.
    def data
      load unless @data
      @data
    end

    # @return [Boolean]
    #   Returns `true` if this resource is loaded.  Accessing attributes or
    #   {#data} on an unloaded resource will trigger a call to {#load}.
    def data_loaded?
      !!@data
    end

    # @param [Hash] options ({})
    # @return [Boolean]
    #   Returns `true` if the Bucket exists.
    def exists?(options = {})
      begin
        wait_until_exists(options.merge(max_attempts: 1))
        true
      rescue Aws::Waiters::Errors::UnexpectedError => e
        raise e.error
      rescue Aws::Waiters::Errors::WaiterFailed
        false
      end
    end

    # @param [Hash] options ({})
    # @option options [Integer] :max_attempts (20)
    # @option options [Float] :delay (5)
    # @option options [Proc] :before_attempt
    # @option options [Proc] :before_wait
    # @return [Bucket]
    def wait_until_exists(options = {})
      options, params = separate_params_and_options(options)
      waiter = Waiters::BucketExists.new(options)
      yield_waiter_and_warn(waiter, &Proc.new) if block_given?
      waiter.wait(params.merge(bucket: @name))
      Bucket.new({
        name: @name,
        client: @client
      })
    end

    # @param [Hash] options ({})
    # @option options [Integer] :max_attempts (20)
    # @option options [Float] :delay (5)
    # @option options [Proc] :before_attempt
    # @option options [Proc] :before_wait
    # @return [Bucket]
    def wait_until_not_exists(options = {})
      options, params = separate_params_and_options(options)
      waiter = Waiters::BucketNotExists.new(options)
      yield_waiter_and_warn(waiter, &Proc.new) if block_given?
      waiter.wait(params.merge(bucket: @name))
      Bucket.new({
        name: @name,
        client: @client
      })
    end

    # @deprecated Use [Aws::S3::Client] #wait_until instead
    #
    # Waiter polls an API operation until a resource enters a desired
    # state.
    #
    # @note The waiting operation is performed on a copy. The original resource remains unchanged
    #
    # ## Basic Usage
    #
    # Waiter will polls until it is successful, it fails by
    # entering a terminal state, or until a maximum number of attempts
    # are made.
    #
    #     # polls in a loop until condition is true
    #     resource.wait_until(options) {|resource| condition}
    #
    # ## Example
    #
    #     instance.wait_until(max_attempts:10, delay:5) {|instance| instance.state.name == 'running' }
    #
    # ## Configuration
    #
    # You can configure the maximum number of polling attempts, and the
    # delay (in seconds) between each polling attempt. The waiting condition is set
    # by passing a block to {#wait_until}:
    #
    #     # poll for ~25 seconds
    #     resource.wait_until(max_attempts:5,delay:5) {|resource|...}
    #
    # ## Callbacks
    #
    # You can be notified before each polling attempt and before each
    # delay. If you throw `:success` or `:failure` from these callbacks,
    # it will terminate the waiter.
    #
    #     started_at = Time.now
    #     # poll for 1 hour, instead of a number of attempts
    #     proc = Proc.new do |attempts, response|
    #       throw :failure if Time.now - started_at > 3600
    #     end
    #
    #       # disable max attempts
    #     instance.wait_until(before_wait:proc, max_attempts:nil) {...}
    #
    # ## Handling Errors
    #
    # When a waiter is successful, it returns the Resource. When a waiter
    # fails, it raises an error.
    #
    #     begin
    #       resource.wait_until(...)
    #     rescue Aws::Waiters::Errors::WaiterFailed
    #       # resource did not enter the desired state in time
    #     end
    #
    #
    # @yield param [Resource] resource to be used in the waiting condition
    #
    # @raise [Aws::Waiters::Errors::FailureStateError] Raised when the waiter terminates
    #   because the waiter has entered a state that it will not transition
    #   out of, preventing success.
    #
    #   yet successful.
    #
    # @raise [Aws::Waiters::Errors::UnexpectedError] Raised when an error is encountered
    #   while polling for a resource that is not expected.
    #
    # @raise [NotImplementedError] Raised when the resource does not
    #
    # @option options [Integer] :max_attempts (10) Maximum number of
    # attempts
    # @option options [Integer] :delay (10) Delay between each
    # attempt in seconds
    # @option options [Proc] :before_attempt (nil) Callback
    # invoked before each attempt
    # @option options [Proc] :before_wait (nil) Callback
    # invoked before each wait
    # @return [Resource] if the waiter was successful
    def wait_until(options = {}, &block)
      self_copy = self.dup
      attempts = 0
      options[:max_attempts] = 10 unless options.key?(:max_attempts)
      options[:delay] ||= 10
      options[:poller] = Proc.new do
        attempts += 1
        if block.call(self_copy)
          [:success, self_copy]
        else
          self_copy.reload unless attempts == options[:max_attempts]
          :retry
        end
      end
      Aws::Waiters::Waiter.new(options).wait({})
    end

    # @!group Actions

    # @example Request syntax with placeholder values
    #
    #   bucket.create({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #     create_bucket_configuration: {
    #       location_constraint: "EU", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
    #     },
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write: "GrantWrite",
    #     grant_write_acp: "GrantWriteACP",
    #   })
    # @param [Hash] options ({})
    # @option options [String] :acl
    #   The canned ACL to apply to the bucket.
    # @option options [Types::CreateBucketConfiguration] :create_bucket_configuration
    # @option options [String] :grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions on
    #   the bucket.
    # @option options [String] :grant_read
    #   Allows grantee to list the objects in the bucket.
    # @option options [String] :grant_read_acp
    #   Allows grantee to read the bucket ACL.
    # @option options [String] :grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    # @option options [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    # @return [Types::CreateBucketOutput]
    def create(options = {})
      options = options.merge(bucket: @name)
      resp = @client.create_bucket(options)
      resp.data
    end

    # @example Request syntax with placeholder values
    #
    #   bucket.delete()
    # @param [Hash] options ({})
    # @return [EmptyStructure]
    def delete(options = {})
      options = options.merge(bucket: @name)
      resp = @client.delete_bucket(options)
      resp.data
    end

    # @example Request syntax with placeholder values
    #
    #   bucket.delete_objects({
    #     delete: { # required
    #       objects: [ # required
    #         {
    #           key: "ObjectKey", # required
    #           version_id: "ObjectVersionId",
    #         },
    #       ],
    #       quiet: false,
    #     },
    #     mfa: "MFA",
    #     request_payer: "requester", # accepts requester
    #   })
    # @param [Hash] options ({})
    # @option options [required, Types::Delete] :delete
    # @option options [String] :mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication device.
    # @option options [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    # @return [Types::DeleteObjectsOutput]
    def delete_objects(options = {})
      options = options.merge(bucket: @name)
      resp = @client.delete_objects(options)
      resp.data
    end

    # @example Request syntax with placeholder values
    #
    #   object = bucket.put_object({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #     body: source_file,
    #     cache_control: "CacheControl",
    #     content_disposition: "ContentDisposition",
    #     content_encoding: "ContentEncoding",
    #     content_language: "ContentLanguage",
    #     content_length: 1,
    #     content_md5: "ContentMD5",
    #     content_type: "ContentType",
    #     expires: Time.now,
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write_acp: "GrantWriteACP",
    #     key: "ObjectKey", # required
    #     metadata: {
    #       "MetadataKey" => "MetadataValue",
    #     },
    #     server_side_encryption: "AES256", # accepts AES256, aws:kms
    #     storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #     website_redirect_location: "WebsiteRedirectLocation",
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     ssekms_key_id: "SSEKMSKeyId",
    #     request_payer: "requester", # accepts requester
    #     tagging: "TaggingHeader",
    #   })
    # @param [Hash] options ({})
    # @option options [String] :acl
    #   The canned ACL to apply to the object.
    # @option options [String, IO] :body
    #   Object data.
    # @option options [String] :cache_control
    #   Specifies caching behavior along the request/reply chain.
    # @option options [String] :content_disposition
    #   Specifies presentational information for the object.
    # @option options [String] :content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the media-type
    #   referenced by the Content-Type header field.
    # @option options [String] :content_language
    #   The language the content is in.
    # @option options [Integer] :content_length
    #   Size of the body in bytes. This parameter is useful when the size of
    #   the body cannot be determined automatically.
    # @option options [String] :content_md5
    #   The base64-encoded 128-bit MD5 digest of the part data.
    # @option options [String] :content_type
    #   A standard MIME type describing the format of the object data.
    # @option options [Time,DateTime,Date,Integer,String] :expires
    #   The date and time at which the object is no longer cacheable.
    # @option options [String] :grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    # @option options [String] :grant_read
    #   Allows grantee to read the object data and its metadata.
    # @option options [String] :grant_read_acp
    #   Allows grantee to read the object ACL.
    # @option options [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    # @option options [required, String] :key
    #   Object key for which the PUT operation was initiated.
    # @option options [Hash<String,String>] :metadata
    #   A map of metadata to store with the object in S3.
    # @option options [String] :server_side_encryption
    #   The Server-side encryption algorithm used when storing this object in
    #   S3 (e.g., AES256, aws:kms).
    # @option options [String] :storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    # @option options [String] :website_redirect_location
    #   If the bucket is configured as a website, redirects requests for this
    #   object to another object in the same bucket or to an external URL.
    #   Amazon S3 stores the value of this header in the object metadata.
    # @option options [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    # @option options [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    # @option options [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    # @option options [String] :ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET and
    #   PUT requests for an object protected by AWS KMS will fail if not made
    #   via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    # @option options [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    # @option options [String] :tagging
    #   The tag-set for the object. The tag-set must be encoded as URL Query
    #   parameters
    # @return [Object]
    def put_object(options = {})
      options = options.merge(bucket: @name)
      resp = @client.put_object(options)
      Object.new(
        bucket_name: @name,
        key: options[:key],
        client: @client
      )
    end

    # @!group Associations

    # @return [BucketAcl]
    def acl
      BucketAcl.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketCors]
    def cors
      BucketCors.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketLifecycle]
    def lifecycle
      BucketLifecycle.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketLifecycleConfiguration]
    def lifecycle_configuration
      BucketLifecycleConfiguration.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketLogging]
    def logging
      BucketLogging.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @example Request syntax with placeholder values
    #
    #   multipart_uploads = bucket.multipart_uploads({
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     key_marker: "KeyMarker",
    #     prefix: "Prefix",
    #     upload_id_marker: "UploadIdMarker",
    #   })
    # @param [Hash] options ({})
    # @option options [String] :delimiter
    #   Character you use to group keys.
    # @option options [String] :encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    # @option options [String] :key_marker
    #   Together with upload-id-marker, this parameter specifies the multipart
    #   upload after which listing should begin.
    # @option options [String] :prefix
    #   Lists in-progress uploads only for those keys that begin with the
    #   specified prefix.
    # @option options [String] :upload_id_marker
    #   Together with key-marker, specifies the multipart upload after which
    #   listing should begin. If key-marker is not specified, the
    #   upload-id-marker parameter is ignored.
    # @return [MultipartUpload::Collection]
    def multipart_uploads(options = {})
      batches = Enumerator.new do |y|
        options = options.merge(bucket: @name)
        resp = @client.list_multipart_uploads(options)
        resp.each_page do |page|
          batch = []
          page.data.uploads.each do |u|
            batch << MultipartUpload.new(
              bucket_name: @name,
              object_key: u.key,
              id: u.upload_id,
              data: u,
              client: @client
            )
          end
          y.yield(batch)
        end
      end
      MultipartUpload::Collection.new(batches)
    end

    # @return [BucketNotification]
    def notification
      BucketNotification.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @param [String] key
    # @return [Object]
    def object(key)
      Object.new(
        bucket_name: @name,
        key: key,
        client: @client
      )
    end

    # @example Request syntax with placeholder values
    #
    #   object_versions = bucket.object_versions({
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     key_marker: "KeyMarker",
    #     prefix: "Prefix",
    #     version_id_marker: "VersionIdMarker",
    #   })
    # @param [Hash] options ({})
    # @option options [String] :delimiter
    #   A delimiter is a character you use to group keys.
    # @option options [String] :encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    # @option options [String] :key_marker
    #   Specifies the key to start with when listing objects in a bucket.
    # @option options [String] :prefix
    #   Limits the response to keys that begin with the specified prefix.
    # @option options [String] :version_id_marker
    #   Specifies the object version you want to start listing from.
    # @return [ObjectVersion::Collection]
    def object_versions(options = {})
      batches = Enumerator.new do |y|
        options = options.merge(bucket: @name)
        resp = @client.list_object_versions(options)
        resp.each_page do |page|
          batch = []
          page.data.versions_delete_markers.each do |v|
            batch << ObjectVersion.new(
              bucket_name: @name,
              object_key: v.key,
              id: v.version_id,
              data: v,
              client: @client
            )
          end
          y.yield(batch)
        end
      end
      ObjectVersion::Collection.new(batches)
    end

    # @example Request syntax with placeholder values
    #
    #   objects = bucket.objects({
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     prefix: "Prefix",
    #     request_payer: "requester", # accepts requester
    #   })
    # @param [Hash] options ({})
    # @option options [String] :delimiter
    #   A delimiter is a character you use to group keys.
    # @option options [String] :encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    # @option options [String] :prefix
    #   Limits the response to keys that begin with the specified prefix.
    # @option options [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the list objects request. Bucket owners need not specify this
    #   parameter in their requests.
    # @return [ObjectSummary::Collection]
    def objects(options = {})
      batches = Enumerator.new do |y|
        options = options.merge(bucket: @name)
        resp = @client.list_objects(options)
        resp.each_page do |page|
          batch = []
          page.data.contents.each do |c|
            batch << ObjectSummary.new(
              bucket_name: @name,
              key: c.key,
              data: c,
              client: @client
            )
          end
          y.yield(batch)
        end
      end
      ObjectSummary::Collection.new(batches)
    end

    # @return [BucketPolicy]
    def policy
      BucketPolicy.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketRequestPayment]
    def request_payment
      BucketRequestPayment.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketTagging]
    def tagging
      BucketTagging.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketVersioning]
    def versioning
      BucketVersioning.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @return [BucketWebsite]
    def website
      BucketWebsite.new(
        bucket_name: @name,
        client: @client
      )
    end

    # @deprecated
    # @api private
    def identifiers
      { name: @name }
    end
    deprecated(:identifiers)

    private

    def extract_name(args, options)
      value = args[0] || options.delete(:name)
      case value
      when String then value
      when nil then raise ArgumentError, "missing required option :name"
      else
        msg = "expected :name to be a String, got #{value.class}"
        raise ArgumentError, msg
      end
    end

    def yield_waiter_and_warn(waiter, &block)
      if !@waiter_block_warned
        msg = "pass options to configure the waiter; "
        msg << "yielding the waiter is deprecated"
        warn(msg)
        @waiter_block_warned = true
      end
      yield(waiter.waiter)
    end

    def separate_params_and_options(options)
      opts = Set.new([:client, :max_attempts, :delay, :before_attempt, :before_wait])
      waiter_opts = {}
      waiter_params = {}
      options.each_pair do |key, value|
        if opts.include?(key)
          waiter_opts[key] = value
        else
          waiter_params[key] = value
        end
      end
      waiter_opts[:client] ||= @client
      [waiter_opts, waiter_params]
    end

    class Collection < Aws::Resources::Collection; end
  end
end
