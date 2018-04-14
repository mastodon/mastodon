# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::S3
  class ObjectVersion

    extend Aws::Deprecations

    # @overload def initialize(bucket_name, object_key, id, options = {})
    #   @param [String] bucket_name
    #   @param [String] object_key
    #   @param [String] id
    #   @option options [Client] :client
    # @overload def initialize(options = {})
    #   @option options [required, String] :bucket_name
    #   @option options [required, String] :object_key
    #   @option options [required, String] :id
    #   @option options [Client] :client
    def initialize(*args)
      options = Hash === args.last ? args.pop.dup : {}
      @bucket_name = extract_bucket_name(args, options)
      @object_key = extract_object_key(args, options)
      @id = extract_id(args, options)
      @data = options.delete(:data)
      @client = options.delete(:client) || Client.new(options)
    end

    # @!group Read-Only Attributes

    # @return [String]
    def bucket_name
      @bucket_name
    end

    # @return [String]
    def object_key
      @object_key
    end

    # @return [String]
    def id
      @id
    end

    # @return [String]
    def etag
      data[:etag]
    end

    # Size in bytes of the object.
    # @return [Integer]
    def size
      data[:size]
    end

    # The class of storage used to store the object.
    # @return [String]
    def storage_class
      data[:storage_class]
    end

    # The object key.
    # @return [String]
    def key
      data[:key]
    end

    # Version ID of an object.
    # @return [String]
    def version_id
      data[:version_id]
    end

    # Specifies whether the object is (true) or is not (false) the latest
    # version of an object.
    # @return [Boolean]
    def is_latest
      data[:is_latest]
    end

    # Date and time the object was last modified.
    # @return [Time]
    def last_modified
      data[:last_modified]
    end

    # @return [Types::Owner]
    def owner
      data[:owner]
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
    # @return [Types::ObjectVersion]
    #   Returns the data for this {ObjectVersion}.
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
    #   object_version.delete({
    #     mfa: "MFA",
    #     request_payer: "requester", # accepts requester
    #   })
    # @param [Hash] options ({})
    # @option options [String] :mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication device.
    # @option options [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    # @return [Types::DeleteObjectOutput]
    def delete(options = {})
      options = options.merge(
        bucket: @bucket_name,
        key: @object_key,
        version_id: @id
      )
      resp = @client.delete_object(options)
      resp.data
    end

    # @example Request syntax with placeholder values
    #
    #   object_version.get({
    #     if_match: "IfMatch",
    #     if_modified_since: Time.now,
    #     if_none_match: "IfNoneMatch",
    #     if_unmodified_since: Time.now,
    #     range: "Range",
    #     response_cache_control: "ResponseCacheControl",
    #     response_content_disposition: "ResponseContentDisposition",
    #     response_content_encoding: "ResponseContentEncoding",
    #     response_content_language: "ResponseContentLanguage",
    #     response_content_type: "ResponseContentType",
    #     response_expires: Time.now,
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #     part_number: 1,
    #   })
    # @param [Hash] options ({})
    # @option options [String] :if_match
    #   Return the object only if its entity tag (ETag) is the same as the one
    #   specified, otherwise return a 412 (precondition failed).
    # @option options [Time,DateTime,Date,Integer,String] :if_modified_since
    #   Return the object only if it has been modified since the specified
    #   time, otherwise return a 304 (not modified).
    # @option options [String] :if_none_match
    #   Return the object only if its entity tag (ETag) is different from the
    #   one specified, otherwise return a 304 (not modified).
    # @option options [Time,DateTime,Date,Integer,String] :if_unmodified_since
    #   Return the object only if it has not been modified since the specified
    #   time, otherwise return a 412 (precondition failed).
    # @option options [String] :range
    #   Downloads the specified range bytes of an object. For more information
    #   about the HTTP Range header, go to
    #   http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
    # @option options [String] :response_cache_control
    #   Sets the Cache-Control header of the response.
    # @option options [String] :response_content_disposition
    #   Sets the Content-Disposition header of the response
    # @option options [String] :response_content_encoding
    #   Sets the Content-Encoding header of the response.
    # @option options [String] :response_content_language
    #   Sets the Content-Language header of the response.
    # @option options [String] :response_content_type
    #   Sets the Content-Type header of the response.
    # @option options [Time,DateTime,Date,Integer,String] :response_expires
    #   Sets the Expires header of the response.
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
    # @option options [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    # @option options [Integer] :part_number
    #   Part number of the object being read. This is a positive integer
    #   between 1 and 10,000. Effectively performs a 'ranged' GET request
    #   for the part specified. Useful for downloading just a part of an
    #   object.
    # @return [Types::GetObjectOutput]
    def get(options = {}, &block)
      options = options.merge(
        bucket: @bucket_name,
        key: @object_key,
        version_id: @id
      )
      resp = @client.get_object(options, &block)
      resp.data
    end

    # @example Request syntax with placeholder values
    #
    #   object_version.head({
    #     if_match: "IfMatch",
    #     if_modified_since: Time.now,
    #     if_none_match: "IfNoneMatch",
    #     if_unmodified_since: Time.now,
    #     range: "Range",
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #     part_number: 1,
    #   })
    # @param [Hash] options ({})
    # @option options [String] :if_match
    #   Return the object only if its entity tag (ETag) is the same as the one
    #   specified, otherwise return a 412 (precondition failed).
    # @option options [Time,DateTime,Date,Integer,String] :if_modified_since
    #   Return the object only if it has been modified since the specified
    #   time, otherwise return a 304 (not modified).
    # @option options [String] :if_none_match
    #   Return the object only if its entity tag (ETag) is different from the
    #   one specified, otherwise return a 304 (not modified).
    # @option options [Time,DateTime,Date,Integer,String] :if_unmodified_since
    #   Return the object only if it has not been modified since the specified
    #   time, otherwise return a 412 (precondition failed).
    # @option options [String] :range
    #   Downloads the specified range bytes of an object. For more information
    #   about the HTTP Range header, go to
    #   http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
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
    # @option options [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    # @option options [Integer] :part_number
    #   Part number of the object being read. This is a positive integer
    #   between 1 and 10,000. Effectively performs a 'ranged' HEAD request
    #   for the part specified. Useful querying about the size of the part and
    #   the number of parts in this object.
    # @return [Types::HeadObjectOutput]
    def head(options = {})
      options = options.merge(
        bucket: @bucket_name,
        key: @object_key,
        version_id: @id
      )
      resp = @client.head_object(options)
      resp.data
    end

    # @!group Associations

    # @return [Object]
    def object
      Object.new(
        bucket_name: @bucket_name,
        key: @object_key,
        client: @client
      )
    end

    # @deprecated
    # @api private
    def identifiers
      {
        bucket_name: @bucket_name,
        object_key: @object_key,
        id: @id
      }
    end
    deprecated(:identifiers)

    private

    def extract_bucket_name(args, options)
      value = args[0] || options.delete(:bucket_name)
      case value
      when String then value
      when nil then raise ArgumentError, "missing required option :bucket_name"
      else
        msg = "expected :bucket_name to be a String, got #{value.class}"
        raise ArgumentError, msg
      end
    end

    def extract_object_key(args, options)
      value = args[1] || options.delete(:object_key)
      case value
      when String then value
      when nil then raise ArgumentError, "missing required option :object_key"
      else
        msg = "expected :object_key to be a String, got #{value.class}"
        raise ArgumentError, msg
      end
    end

    def extract_id(args, options)
      value = args[2] || options.delete(:id)
      case value
      when String then value
      when nil then raise ArgumentError, "missing required option :id"
      else
        msg = "expected :id to be a String, got #{value.class}"
        raise ArgumentError, msg
      end
    end

    class Collection < Aws::Resources::Collection

      # @!group Batch Actions

      # @example Request syntax with placeholder values
      #
      #   object_version.batch_delete!({
      #     mfa: "MFA",
      #     request_payer: "requester", # accepts requester
      #   })
      # @param options ({})
      # @option options [String] :mfa
      #   The concatenation of the authentication device's serial number, a
      #   space, and the value that is displayed on your authentication device.
      # @option options [String] :request_payer
      #   Confirms that the requester knows that she or he will be charged for
      #   the request. Bucket owners need not specify this parameter in their
      #   requests. Documentation on downloading objects from requester pays
      #   buckets can be found at
      #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
      # @return [void]
      def batch_delete!(options = {})
        batch_enum.each do |batch|
          params = Aws::Util.copy_hash(options)
          params[:bucket] = batch[0].bucket_name
          params[:delete] ||= {}
          params[:delete][:objects] ||= []
          batch.each do |item|
            params[:delete][:objects] << {
              key: item.object_key,
              version_id: item.id
            }
          end
          batch[0].client.delete_objects(params)
        end
        nil
      end

      # @!endgroup

    end
  end
end
