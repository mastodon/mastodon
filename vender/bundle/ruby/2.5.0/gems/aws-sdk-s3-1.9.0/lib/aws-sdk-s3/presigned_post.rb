require 'openssl'
require 'base64'

module Aws
  module S3

    # @note Normally you do not need to construct a {PresignedPost} yourself.
    #   See {Bucket#presigned_post} and {Object#presigned_post}.
    #
    # ## Basic Usage
    #
    # To generate a presigned post, you need AWS credentials, the region
    # your bucket is in, and the name of your bucket. You can apply constraints
    # to the post object as options to {#initialize} or by calling
    # methods such as {#key} and {#content_length_range}.
    #
    # The following two examples are equivalent.
    #
    # ```ruby
    # post = Aws::S3::PresignedPost.new(creds, region, bucket, {
    #   key: '/uploaded/object/key',
    #   content_length_range: 0..1024,
    #   acl: 'public-read',
    #   metadata: {
    #     'original-filename' => '${filename}'
    #   }
    # })
    # post.fields
    # #=> { ... }
    #
    # post = Aws::S3::PresignedPost.new(creds, region, bucket).
    #   key('/uploaded/object/key').
    #   content_length_range(0..1024).
    #   acl('public-read').
    #   metadata('original-filename' => '${filename}').
    #   fields
    # #=> { ... }
    # ```
    #
    # ## HTML Forms
    #
    # You can use a {PresignedPost} object to build an HTML form. It is
    # recommended to use some helper to build the form tag and input
    # tags that properly escapes values.
    #
    # ### Form Tag
    #
    # To upload a file to Amazon S3 using a browser, you need to create
    # a post form. The {#url} method returns the value you should use
    # as the form action.
    #
    # ```erb
    # <form action="<%= @post.url %>" method="post" enctype="multipart/form-data">
    #   ...
    # </form>
    # ```
    #
    # The follow attributes must be set on the form:
    #
    # * `action` - This must be the {#url}.
    # * `method` - This must be `post`.
    # * `enctype` - This must be `multipart/form-data`.
    #
    # ### Form Fields
    #
    # The {#fields} method returns a hash of form fields to render inside
    # the form. Typically these are rendered as hidden input fields.
    #
    # ```erb
    # <% @post.fields.each do |name, value| %>
    #   <input type="hidden" name="<%= name %>" value="<%= value %>"/>
    # <% end %>
    # ```
    #
    # Lastly, the form must have a file field with the name `file`.
    #
    # ```erb
    # <input type="file" name="file"/>
    # ```
    #
    # ## Post Policy
    #
    # When you construct a {PresignedPost}, you must specify every form
    # field name that will be posted by the browser. If you omit a form
    # field sent by the browser, Amazon S3 will reject the request.
    # You can specify accepted form field values three ways:
    #
    # * Specify exactly what the value must be.
    # * Specify what value the field starts with.
    # * Specify the field may have any value.
    #
    # ### Field Equals
    #
    # You can specify that a form field must be a certain value.
    # Simply pass an option like `:content_type` to the constructor,
    # or call the associated method.
    #
    # ```ruby
    # post = Aws::S3::PresignedPost.new(creds, region, bucket).
    # post.content_type('text/plain')
    # ```
    #
    # If any of the given values are changed by the user in the form, then
    # Amazon S3 will reject the POST request.
    #
    # ### Field Starts With
    #
    # You can specify prefix values for many of the POST form fields.
    # To specify a required prefix, use the `:<fieldname>_starts_with`
    # option or call the associated `#<field_name>_starts_with` method.
    #
    # ```ruby
    # post = Aws::S3::PresignedPost.new(creds, region, bucket, {
    #   key_starts_with: '/images/',
    #   content_type_starts_with: 'image/',
    #   # ...
    # })
    # ```
    #
    # When using starts with, the form must contain a field where the
    # user can specify the value. The {PresignedPost} will not add
    # a value for these fields.
    #
    # ### Any Field Value
    #
    # To white-list a form field to send any value, you can name that
    # field with `:allow_any` or {#allow_any}.
    #
    # ```ruby
    # post = Aws::S3::PresignedPost.new(creds, region, bucket, {
    #   key: 'object-key',
    #   allow_any: ['Filename'],
    #   # ...
    # })
    # ```
    #
    # ### Metadata
    #
    # You can add rules for metadata fields using `:metadata`, {#metadata},
    # `:metadata_starts_with` and {#metadata_starts_with}. Unlike other
    # form fields, you pass a hash value to these options/methods:
    #
    # ```ruby
    # post = Aws::S3::PresignedPost.new(creds, region, bucket).
    #   key('/fixed/key').
    #   metadata(foo: 'bar')
    #
    # post.fields['x-amz-meta-foo']
    # #=> 'bar'
    # ```
    #
    # ### The `${filename}` Variable
    #
    # The string `${filename}` is automatically replaced with the name of the
    # file provided by the user and is recognized by all form fields. It is
    # not supported with `starts_with` conditions.
    #
    # If the browser or client provides a full or partial path to the file,
    # only the text following the last slash (/) or backslash (\) will be used
    # (e.g., "C:\Program Files\directory1\file.txt" will be interpreted
    # as "file.txt"). If no file or file name is provided, the variable is
    # replaced with an empty string.
    #
    # In the following example, we use `${filename}` to store the original
    # filename in the `x-amz-meta-` hash with the uploaded object.
    #
    # ```ruby
    # post = Aws::S3::PresignedPost.new(creds, region, bucket, {
    #   key: '/fixed/key',
    #   metadata: {
    #     'original-filename': '${filename}'
    #   }
    # })
    # ```
    #
    class PresignedPost

      # @param [Credentials] credentials Security credentials for signing
      #   the post policy.
      # @param [String] bucket_region Region of the target bucket.
      # @param [String] bucket_name Name of the target bucket.
      # @option options [Time] :signature_expiration Specify when the signature on
      #   the post will expire. Defaults to one hour from creation of the
      #   presigned post. May not exceed one week from creation time.
      # @option options [String] :key See {PresignedPost#key}.
      # @option options [String] :key_starts_with See {PresignedPost#key_starts_with}.
      # @option options [String] :acl See {PresignedPost#acl}.
      # @option options [String] :acl_starts_with See {PresignedPost#acl_starts_with}.
      # @option options [String] :cache_control See {PresignedPost#cache_control}.
      # @option options [String] :cache_control_starts_with See {PresignedPost#cache_control_starts_with}.
      # @option options [String] :content_type See {PresignedPost#content_type}.
      # @option options [String] :content_type_starts_with See {PresignedPost#content_type_starts_with}.
      # @option options [String] :content_disposition See {PresignedPost#content_disposition}.
      # @option options [String] :content_disposition_starts_with See {PresignedPost#content_disposition_starts_with}.
      # @option options [String] :content_encoding See {PresignedPost#content_encoding}.
      # @option options [String] :content_encoding_starts_with See {PresignedPost#content_encoding_starts_with}.
      # @option options [String] :expires See {PresignedPost#expires}.
      # @option options [String] :expires_starts_with See {PresignedPost#expires_starts_with}.
      # @option options [Range<Integer>] :content_length_range See {PresignedPost#content_length_range}.
      # @option options [String] :success_action_redirect See {PresignedPost#success_action_redirect}.
      # @option options [String] :success_action_redirect_starts_with See {PresignedPost#success_action_redirect_starts_with}.
      # @option options [String] :success_action_status See {PresignedPost#success_action_status}.
      # @option options [String] :storage_class See {PresignedPost#storage_class}.
      # @option options [String] :website_redirect_location See {PresignedPost#website_redirect_location}.
      # @option options [Hash<String,String>] :metadata See {PresignedPost#metadata}.
      # @option options [Hash<String,String>] :metadata_starts_with See {PresignedPost#metadata_starts_with}.
      # @option options [String] :server_side_encryption See {PresignedPost#server_side_encryption}.
      # @option options [String] :server_side_encryption_aws_kms_key_id See {PresignedPost#server_side_encryption_aws_kms_key_id}.
      # @option options [String] :server_side_encryption_customer_algorithm See {PresignedPost#server_side_encryption_customer_algorithm}.
      # @option options [String] :server_side_encryption_customer_key See {PresignedPost#server_side_encryption_customer_key}.
      def initialize(credentials, bucket_region, bucket_name, options = {})
        @credentials = credentials.credentials
        @bucket_region = bucket_region
        @bucket_name = bucket_name
        @url = options.delete(:url) || bucket_url
        @fields = {}
        @key_set = false
        @signature_expiration = Time.now + 3600
        @conditions = [{ 'bucket' => @bucket_name }]
        options.each do |option_name, option_value|
          case option_name
          when :allow_any then allow_any(option_value)
          when :signature_expiration then @signature_expiration = option_value
          else send("#{option_name}", option_value)
          end
        end
      end

      # @return [String] The URL to post a file upload to.  This should be
      #   the form action.
      attr_reader :url

      # @return [Hash] A hash of fields to render in an HTML form
      #   as hidden input fields.
      def fields
        check_required_values!
        datetime = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
        fields = @fields.dup
        fields.update('policy' => policy(datetime))
        fields.update(signature_fields(datetime))
        fields.update('x-amz-signature' => signature(datetime, fields['policy']))
      end

      # A list of form fields to white-list with any value.
      # @param [Sting, Array<String>] field_names
      # @return [self]
      def allow_any(*field_names)
        field_names.flatten.each do |field_name|
          @key_set = true if field_name.to_s == 'key'
          starts_with(field_name, '')
        end
        self
      end

      # @api private
      def self.define_field(field, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        field_name = args.last || field.to_s

        define_method("#{field}") do |value|
          with(field_name, value)
        end

        if options[:starts_with]
          define_method("#{field}_starts_with") do |value|
            starts_with(field_name, value)
          end
        end
      end

      # @!group Fields

      # The key to use for the uploaded object. Use can use `${filename}`
      # as a variable in the key. This will be replaced with the name
      # of the file as provided by the user.
      #
      # For example, if the key is given as `/user/betty/${filename}` and
      # the file uploaded is named `lolcatz.jpg`, the resultant key will
      # be `/user/betty/lolcatz.jpg`.
      #
      # @param [String] key
      # @see http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html)
      # @return [self]
      def key(key)
        @key_set = true
        with('key', key)
      end

      # Specify a prefix the uploaded
      # @param [String] prefix
      # @see #key
      # @return [self]
      def key_starts_with(prefix)
        @key_set = true
        starts_with('key', prefix)
      end

      # @!method acl(canned_acl)
      #   Specify the cannedl ACL (access control list) for the object.
      #   May be one of the following values:
      #
      #     * `private`
      #     * `public-read`
      #     * `public-read-write`
      #     * `authenticated-read`
      #     * `bucket-owner-read`
      #     * `bucket-owner-full-control`
      #
      #   @param [String] canned_acl
      #   @see http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
      #   @return [self]
      #
      # @!method acl_starts_with(prefix)
      #   @param [String] prefix
      #   @see #acl
      #   @return [self]
      define_field(:acl, starts_with: true)

      # @!method cache_control(value)
      #   Specify caching behavior along the request/reply chain.
      #   @param [String] value
      #   @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9.
      #   @return [self]
      #
      # @!method cache_control_starts_with(prefix)
      #   @param [String] prefix
      #   @see #cache_control
      #   @return [self]
      define_field(:cache_control, 'Cache-Control', starts_with: true)

      # @return [String]
      # @!method content_type(value)
      #   A standard MIME type describing the format of the contents.
      #   @param [String] value
      #   @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21
      #   @return [self]
      #
      # @!method content_type_starts_with(prefix)
      #   @param [String] prefix
      #   @see #content_type
      #   @return [self]
      define_field(:content_type, 'Content-Type', starts_with: true)

      # @!method content_disposition(value)
      #   Specifies presentational information for the object.
      #   @param [String] value
      #   @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.5.1
      #   @return [self]
      #
      # @!method content_disposition_starts_with(prefix)
      #   @param [String] prefix
      #   @see #content_disposition
      #   @return [self]
      define_field(:content_disposition, 'Content-Disposition', starts_with: true)

      # @!method content_encoding(value)
      #   Specifies what content encodings have been applied to the object
      #   and thus what decoding mechanisms must be applied to obtain the
      #   media-type referenced by the Content-Type header field.
      #   @param [String] value
      #   @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.11
      #   @return [self]
      #
      # @!method content_encoding_starts_with(prefix)
      #   @param [String] prefix
      #   @see #content_encoding
      #   @return [self]
      define_field(:content_encoding, 'Content-Encoding', starts_with: true)

      # The date and time at which the object is no longer cacheable.
      # @note This does not affect the expiration of the presigned post
      #   signature.
      # @param [Time] time
      # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21
      # @return [self]
      def expires(time)
        with('Expires', time.httpdate)
      end

      # @param [String] prefix
      # @see #expires
      # @return [self]
      def expires_starts_with(prefix)
        starts_with('Expires', prefix)
      end

      # The minimum and maximum allowable size for the uploaded content.
      # @param [Range<Integer>] byte_range
      # @return [self]
      def content_length_range(byte_range)
        min = byte_range.begin
        max = byte_range.end
        max -= 1 if byte_range.exclude_end?
        @conditions << ['content-length-range', min, max]
        self
      end

      # @!method success_action_redirect(value)
      #   The URL to which the client is redirected
      #   upon successful upload. If {#success_action_redirect} is not
      #   specified, Amazon S3 returns the empty document type specified
      #   by {#success_action_status}.
      #
      #   If Amazon S3 cannot interpret the URL, it acts as if the field
      #   is not present.  If the upload fails, Amazon S3 displays an error
      #   and does not redirect the user to a URL.
      #
      #   @param [String] value
      #   @return [self]
      #
      # @!method success_action_redirect_starts_with(prefix)
      #   @param [String] prefix
      #   @see #success_action_redirect
      #   @return [self]
      define_field(:success_action_redirect, starts_with: true)

      # @!method success_action_status(value)
      #   The status code returned to the client upon
      #   successful upload if {#success_action_redirect} is not
      #   specified.
      #
      #   Accepts the values `200`, `201`, or `204` (default).
      #
      #   If the value is set to 200 or 204, Amazon S3 returns an empty
      #   document with a 200 or 204 status code. If the value is set to 201,
      #   Amazon S3 returns an XML document with a 201 status code.
      #
      #   If the value is not set or if it is set to an invalid value, Amazon
      #   S3 returns an empty document with a 204 status code.
      #
      #   @param [String] value The status code returned to the client upon
      #   @return [self]
      define_field(:success_action_status)

      # @!method storage_class(value)
      #   Storage class to use for storing the object. Defaults to
      #   `STANDARD`. Must be one of:
      #
      #   * `STANDARD`
      #   * `REDUCED_REDUNDANCY`
      #
      #   You cannot specify `GLACIER` as the storage class. To transition
      #   objects to the GLACIER storage class you can use lifecycle
      #   configuration.
      #   @param [String] value Storage class to use for storing the
      #   @return [self]
      define_field(:storage_class, 'x-amz-storage-class')

      # @!method website_redirect_location(value)
      #   If the bucket is configured as a website,
      #   redirects requests for this object to another object in the
      #   same bucket or to an external URL. Amazon S3 stores this value
      #   in the object metadata.
      #
      #   The value must be prefixed by, "/", "http://" or "https://".
      #   The length of the value is limited to 2K.
      #
      #   @param [String] value
      #   @see http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html
      #   @see http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html
      #   @see http://docs.aws.amazon.com/AmazonS3/latest/dev/how-to-page-redirect.html
      #   @return [self]
      define_field(:website_redirect_location, 'x-amz-website-redirect-location')

      # Metadata hash to store with the uploaded object. Hash keys will be
      # prefixed with "x-amz-meta-".
      # @param [Hash<String,String>] hash
      # @return [self]
      def metadata(hash)
        hash.each do |key, value|
          with("x-amz-meta-#{key}", value)
        end
        self
      end

      # Specify allowable prefix for each key in the metadata hash.
      # @param [Hash<String,String>] hash
      # @see #metadata
      # @return [self]
      def metadata_starts_with(hash)
        hash.each do |key, value|
          starts_with("x-amz-meta-#{key}", value)
        end
        self
      end

      # @!endgroup

      # @!group Server-Side Encryption Fields

      # @!method server_side_encryption(value)
      #   Specifies a server-side encryption algorithm to use when Amazon
      #   S3 creates an object. Valid values include:
      #
      #   * `aws:kms`
      #   * `AES256`
      #
      #   @param [String] value
      #   @return [self]
      define_field(:server_side_encryption, 'x-amz-server-side-encryption')

      # @!method server_side_encryption_aws_kms_key_id(value)
      #   If {#server_side_encryption} is called with the value of `aws:kms`,
      #   this method specifies the ID of the AWS Key Management Service
      #   (KMS) master encryption key to use for the object.
      #   @param [String] value
      #   @return [self]
      define_field(:server_side_encryption_aws_kms_key_id, 'x-amz-server-side-encryption-aws-kms-key-id')

      # @!endgroup

      # @!group Server-Side Encryption with Customer-Provided Key Fields

      # @!method server_side_encryption_customer_algorithm(value)
      #   Specifies the algorithm to use to when encrypting the object.
      #   Must be set to `AES256` when using customer-provided encryption
      #   keys. Must also call {#server_side_encryption_customer_key}.
      #   @param [String] value
      #   @see #server_side_encryption_customer_key
      #   @return [self]
      define_field(:server_side_encryption_customer_algorithm, 'x-amz-server-side-encryption-customer-algorithm')

      # Specifies the customer-provided encryption key for Amazon S3 to use
      # in encrypting data. This value is used to store the object and then
      # it is discarded; Amazon does not store the encryption key.
      #
      # You must also call {#server_side_encryption_customer_algorithm}.
      #
      # @param [String] value
      # @see #server_side_encryption_customer_algorithm
      # @return [self]
      def server_side_encryption_customer_key(value)
        field_name = 'x-amz-server-side-encryption-customer-key'
        with(field_name, base64(value))
        with(field_name + '-MD5', base64(OpenSSL::Digest::MD5.digest(value)))
      end

      # @param [String] prefix
      # @see #server_side_encryption_customer_key
      # @return [self]
      def server_side_encryption_customer_key_starts_with(prefix)
        field_name = 'x-amz-server-side-encryption-customer-key'
        starts_with(field_name, prefix)
      end

      # @!endgroup

      private

      def with(field_name, value)
        fvar = '${filename}'
        if index = value.rindex(fvar)
          if index + fvar.size == value.size
            @fields[field_name] = value
            starts_with(field_name, value[0,index])
          else
            msg = "${filename} only supported at the end of #{field_name}"
            raise ArgumentError, msg
          end
        else
          @fields[field_name] = value.to_s
          @conditions << { field_name => value.to_s }
        end
        self
      end

      def starts_with(field_name, value, &block)
        @conditions << ['starts-with', "$#{field_name}", value.to_s]
        self
      end

      def check_required_values!
        unless @key_set
          msg = "key required; you must provide a key via :key, "
          msg << ":key_starts_with, or :allow_any => ['key']"
          raise msg
        end
      end

      def bucket_url
        url = Aws::Partitions::EndpointProvider.resolve(@bucket_region, 's3')
        url = URI.parse(url)
        if Plugins::BucketDns.dns_compatible?(@bucket_name, true)
          url.host = @bucket_name + '.' + url.host
        else
          url.path = '/' + @bucket_name
        end
        url.to_s
      end

      # @return [Hash]
      def policy(datetime)
        check_required_values!
        policy = {}
        policy['expiration'] = @signature_expiration.utc.iso8601
        policy['conditions'] = @conditions.dup
        signature_fields(datetime).each do |name, value|
          policy['conditions'] << { name => value }
        end
        base64(Json.dump(policy))
      end

      def signature_fields(datetime)
        fields = {}
        fields['x-amz-credential'] = credential_scope(datetime)
        fields['x-amz-algorithm'] = 'AWS4-HMAC-SHA256'
        fields['x-amz-date'] = datetime
        if session_token = @credentials.session_token
          fields['x-amz-security-token'] = session_token
        end
        fields
      end

      def signature(datetime, string_to_sign)
        k_secret = @credentials.secret_access_key
        k_date = hmac("AWS4" + k_secret, datetime[0,8])
        k_region = hmac(k_date, @bucket_region)
        k_service = hmac(k_region, 's3')
        k_credentials = hmac(k_service, 'aws4_request')
        hexhmac(k_credentials, string_to_sign)
      end

      def hmac(key, value)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
      end

      def hexhmac(key, value)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, value)
      end

      def credential_scope(datetime)
        parts = []
        parts << @credentials.access_key_id
        parts << datetime[0,8]
        parts << @bucket_region
        parts << 's3'
        parts << 'aws4_request'
        parts.join('/')
      end

      def base64(str)
        Base64.strict_encode64(str)
      end

    end
  end
end
