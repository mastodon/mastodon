# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

require 'seahorse/client/plugins/content_length.rb'
require 'aws-sdk-core/plugins/credentials_configuration.rb'
require 'aws-sdk-core/plugins/logging.rb'
require 'aws-sdk-core/plugins/param_converter.rb'
require 'aws-sdk-core/plugins/param_validator.rb'
require 'aws-sdk-core/plugins/user_agent.rb'
require 'aws-sdk-core/plugins/helpful_socket_errors.rb'
require 'aws-sdk-core/plugins/retry_errors.rb'
require 'aws-sdk-core/plugins/global_configuration.rb'
require 'aws-sdk-core/plugins/regional_endpoint.rb'
require 'aws-sdk-core/plugins/response_paging.rb'
require 'aws-sdk-core/plugins/stub_responses.rb'
require 'aws-sdk-core/plugins/idempotency_token.rb'
require 'aws-sdk-core/plugins/jsonvalue_converter.rb'
require 'aws-sdk-core/plugins/protocols/rest_xml.rb'
require 'aws-sdk-s3/plugins/accelerate.rb'
require 'aws-sdk-s3/plugins/dualstack.rb'
require 'aws-sdk-s3/plugins/bucket_dns.rb'
require 'aws-sdk-s3/plugins/expect_100_continue.rb'
require 'aws-sdk-s3/plugins/http_200_errors.rb'
require 'aws-sdk-s3/plugins/s3_host_id.rb'
require 'aws-sdk-s3/plugins/get_bucket_location_fix.rb'
require 'aws-sdk-s3/plugins/location_constraint.rb'
require 'aws-sdk-s3/plugins/md5s.rb'
require 'aws-sdk-s3/plugins/redirects.rb'
require 'aws-sdk-s3/plugins/sse_cpk.rb'
require 'aws-sdk-s3/plugins/url_encoded_keys.rb'
require 'aws-sdk-s3/plugins/s3_signer.rb'
require 'aws-sdk-s3/plugins/bucket_name_restrictions.rb'

Aws::Plugins::GlobalConfiguration.add_identifier(:s3)

module Aws::S3
  class Client < Seahorse::Client::Base

    include Aws::ClientStubs

    @identifier = :s3

    set_api(ClientApi::API)

    add_plugin(Seahorse::Client::Plugins::ContentLength)
    add_plugin(Aws::Plugins::CredentialsConfiguration)
    add_plugin(Aws::Plugins::Logging)
    add_plugin(Aws::Plugins::ParamConverter)
    add_plugin(Aws::Plugins::ParamValidator)
    add_plugin(Aws::Plugins::UserAgent)
    add_plugin(Aws::Plugins::HelpfulSocketErrors)
    add_plugin(Aws::Plugins::RetryErrors)
    add_plugin(Aws::Plugins::GlobalConfiguration)
    add_plugin(Aws::Plugins::RegionalEndpoint)
    add_plugin(Aws::Plugins::ResponsePaging)
    add_plugin(Aws::Plugins::StubResponses)
    add_plugin(Aws::Plugins::IdempotencyToken)
    add_plugin(Aws::Plugins::JsonvalueConverter)
    add_plugin(Aws::Plugins::Protocols::RestXml)
    add_plugin(Aws::S3::Plugins::Accelerate)
    add_plugin(Aws::S3::Plugins::Dualstack)
    add_plugin(Aws::S3::Plugins::BucketDns)
    add_plugin(Aws::S3::Plugins::Expect100Continue)
    add_plugin(Aws::S3::Plugins::Http200Errors)
    add_plugin(Aws::S3::Plugins::S3HostId)
    add_plugin(Aws::S3::Plugins::GetBucketLocationFix)
    add_plugin(Aws::S3::Plugins::LocationConstraint)
    add_plugin(Aws::S3::Plugins::Md5s)
    add_plugin(Aws::S3::Plugins::Redirects)
    add_plugin(Aws::S3::Plugins::SseCpk)
    add_plugin(Aws::S3::Plugins::UrlEncodedKeys)
    add_plugin(Aws::S3::Plugins::S3Signer)
    add_plugin(Aws::S3::Plugins::BucketNameRestrictions)

    # @option options [required, Aws::CredentialProvider] :credentials
    #   Your AWS credentials. This can be an instance of any one of the
    #   following classes:
    #
    #   * `Aws::Credentials` - Used for configuring static, non-refreshing
    #     credentials.
    #
    #   * `Aws::InstanceProfileCredentials` - Used for loading credentials
    #     from an EC2 IMDS on an EC2 instance.
    #
    #   * `Aws::SharedCredentials` - Used for loading credentials from a
    #     shared file, such as `~/.aws/config`.
    #
    #   * `Aws::AssumeRoleCredentials` - Used when you need to assume a role.
    #
    #   When `:credentials` are not configured directly, the following
    #   locations will be searched for credentials:
    #
    #   * `Aws.config[:credentials]`
    #   * The `:access_key_id`, `:secret_access_key`, and `:session_token` options.
    #   * ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']
    #   * `~/.aws/credentials`
    #   * `~/.aws/config`
    #   * EC2 IMDS instance profile - When used by default, the timeouts are
    #     very aggressive. Construct and pass an instance of
    #     `Aws::InstanceProfileCredentails` to enable retries and extended
    #     timeouts.
    #
    # @option options [required, String] :region
    #   The AWS region to connect to.  The configured `:region` is
    #   used to determine the service `:endpoint`. When not passed,
    #   a default `:region` is search for in the following locations:
    #
    #   * `Aws.config[:region]`
    #   * `ENV['AWS_REGION']`
    #   * `ENV['AMAZON_REGION']`
    #   * `ENV['AWS_DEFAULT_REGION']`
    #   * `~/.aws/credentials`
    #   * `~/.aws/config`
    #
    # @option options [String] :access_key_id
    #
    # @option options [Boolean] :compute_checksums (true)
    #   When `true` a MD5 checksum will be computed for every request that
    #   sends a body.  When `false`, MD5 checksums will only be computed
    #   for operations that require them.  Checksum errors returned by Amazon
    #   S3 are automatically retried up to `:retry_limit` times.
    #
    # @option options [Boolean] :convert_params (true)
    #   When `true`, an attempt is made to coerce request parameters into
    #   the required types.
    #
    # @option options [String] :endpoint
    #   The client endpoint is normally constructed from the `:region`
    #   option. You should only configure an `:endpoint` when connecting
    #   to test endpoints. This should be avalid HTTP(S) URI.
    #
    # @option options [Boolean] :follow_redirects (true)
    #   When `true`, this client will follow 307 redirects returned
    #   by Amazon S3.
    #
    # @option options [Boolean] :force_path_style (false)
    #   When set to `true`, the bucket name is always left in the
    #   request URI and never moved to the host as a sub-domain.
    #
    # @option options [Aws::Log::Formatter] :log_formatter (Aws::Log::Formatter.default)
    #   The log formatter.
    #
    # @option options [Symbol] :log_level (:info)
    #   The log level to send messages to the `:logger` at.
    #
    # @option options [Logger] :logger
    #   The Logger instance to send log messages to.  If this option
    #   is not set, logging will be disabled.
    #
    # @option options [String] :profile ("default")
    #   Used when loading credentials from the shared credentials file
    #   at HOME/.aws/credentials.  When not specified, 'default' is used.
    #
    # @option options [Boolean] :require_https_for_sse_cpk (true)
    #   When `true`, the endpoint **must** be HTTPS for all operations
    #   where server-side-encryption is used with customer-provided keys.
    #   This should only be disabled for local testing.
    #
    # @option options [Integer] :retry_limit (3)
    #   The maximum number of times to retry failed requests.  Only
    #   ~ 500 level server errors and certain ~ 400 level client errors
    #   are retried.  Generally, these are throttling errors, data
    #   checksum errors, networking errors, timeout errors and auth
    #   errors from expired credentials.
    #
    # @option options [String] :secret_access_key
    #
    # @option options [String] :session_token
    #
    # @option options [Boolean] :stub_responses (false)
    #   Causes the client to return stubbed responses. By default
    #   fake responses are generated and returned. You can specify
    #   the response data to return or errors to raise by calling
    #   {ClientStubs#stub_responses}. See {ClientStubs} for more information.
    #
    #   ** Please note ** When response stubbing is enabled, no HTTP
    #   requests are made, and retries are disabled.
    #
    # @option options [Boolean] :use_accelerate_endpoint (false)
    #   When set to `true`, accelerated bucket endpoints will be used
    #   for all object operations. You must first enable accelerate for
    #   each bucket.  [Go here for more information](http://docs.aws.amazon.com/AmazonS3/latest/dev/transfer-acceleration.html).
    #
    # @option options [Boolean] :use_dualstack_endpoint (false)
    #   When set to `true`, IPv6-compatible bucket endpoints will be used
    #   for all operations.
    #
    # @option options [Boolean] :validate_params (true)
    #   When `true`, request parameters are validated before
    #   sending the request.
    #
    def initialize(*args)
      super
    end

    # @!group API Operations

    # Aborts a multipart upload.
    #
    # To verify that all parts have been removed, so you don't get charged
    # for the part storage, you should call the List Parts operation and
    # ensure the parts list is empty.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [required, String] :upload_id
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::AbortMultipartUploadOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::AbortMultipartUploadOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To abort a multipart upload
    #
    #   # The following example aborts a multipart upload.
    #
    #   resp = client.abort_multipart_upload({
    #     bucket: "examplebucket", 
    #     key: "bigobject", 
    #     upload_id: "xadcOB_7YPBOJuoFiQ9cz4P3Pe6FIZwO4f7wN93uHsNBEw97pl5eNwzExg0LAT2dUN91cOmrEQHDsP3WA60CEg--", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.abort_multipart_upload({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     upload_id: "MultipartUploadId", # required
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AbortMultipartUpload AWS API Documentation
    #
    # @overload abort_multipart_upload(params = {})
    # @param [Hash] params ({})
    def abort_multipart_upload(params = {}, options = {})
      req = build_request(:abort_multipart_upload, params)
      req.send_request(options)
    end

    # Completes a multipart upload by assembling previously uploaded parts.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [Types::CompletedMultipartUpload] :multipart_upload
    #
    # @option params [required, String] :upload_id
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::CompleteMultipartUploadOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::CompleteMultipartUploadOutput#location #location} => String
    #   * {Types::CompleteMultipartUploadOutput#bucket #bucket} => String
    #   * {Types::CompleteMultipartUploadOutput#key #key} => String
    #   * {Types::CompleteMultipartUploadOutput#expiration #expiration} => String
    #   * {Types::CompleteMultipartUploadOutput#etag #etag} => String
    #   * {Types::CompleteMultipartUploadOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::CompleteMultipartUploadOutput#version_id #version_id} => String
    #   * {Types::CompleteMultipartUploadOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::CompleteMultipartUploadOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To complete multipart upload
    #
    #   # The following example completes a multipart upload.
    #
    #   resp = client.complete_multipart_upload({
    #     bucket: "examplebucket", 
    #     key: "bigobject", 
    #     multipart_upload: {
    #       parts: [
    #         {
    #           etag: "\"d8c2eafd90c266e19ab9dcacc479f8af\"", 
    #           part_number: 1, 
    #         }, 
    #         {
    #           etag: "\"d8c2eafd90c266e19ab9dcacc479f8af\"", 
    #           part_number: 2, 
    #         }, 
    #       ], 
    #     }, 
    #     upload_id: "7YPBOJuoFiQ9cz4P3Pe6FIZwO4f7wN93uHsNBEw97pl5eNwzExg0LAT2dUN91cOmrEQHDsP3WA60CEg--", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     bucket: "acexamplebucket", 
    #     etag: "\"4d9031c7644d8081c2829f4ea23c55f7-2\"", 
    #     key: "bigobject", 
    #     location: "https://examplebucket.s3.amazonaws.com/bigobject", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.complete_multipart_upload({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     multipart_upload: {
    #       parts: [
    #         {
    #           etag: "ETag",
    #           part_number: 1,
    #         },
    #       ],
    #     },
    #     upload_id: "MultipartUploadId", # required
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.location #=> String
    #   resp.bucket #=> String
    #   resp.key #=> String
    #   resp.expiration #=> String
    #   resp.etag #=> String
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.version_id #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CompleteMultipartUpload AWS API Documentation
    #
    # @overload complete_multipart_upload(params = {})
    # @param [Hash] params ({})
    def complete_multipart_upload(params = {}, options = {})
      req = build_request(:complete_multipart_upload, params)
      req.send_request(options)
    end

    # Creates a copy of an object that is already stored in Amazon S3.
    #
    # @option params [String] :acl
    #   The canned ACL to apply to the object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :cache_control
    #   Specifies caching behavior along the request/reply chain.
    #
    # @option params [String] :content_disposition
    #   Specifies presentational information for the object.
    #
    # @option params [String] :content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the media-type
    #   referenced by the Content-Type header field.
    #
    # @option params [String] :content_language
    #   The language the content is in.
    #
    # @option params [String] :content_type
    #   A standard MIME type describing the format of the object data.
    #
    # @option params [required, String] :copy_source
    #   The name of the source bucket and key name of the source object,
    #   separated by a slash (/). Must be URL-encoded.
    #
    # @option params [String] :copy_source_if_match
    #   Copies the object if its entity tag (ETag) matches the specified tag.
    #
    # @option params [Time,DateTime,Date,Integer,String] :copy_source_if_modified_since
    #   Copies the object if it has been modified since the specified time.
    #
    # @option params [String] :copy_source_if_none_match
    #   Copies the object if its entity tag (ETag) is different than the
    #   specified ETag.
    #
    # @option params [Time,DateTime,Date,Integer,String] :copy_source_if_unmodified_since
    #   Copies the object if it hasn't been modified since the specified
    #   time.
    #
    # @option params [Time,DateTime,Date,Integer,String] :expires
    #   The date and time at which the object is no longer cacheable.
    #
    # @option params [String] :grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    #
    # @option params [String] :grant_read
    #   Allows grantee to read the object data and its metadata.
    #
    # @option params [String] :grant_read_acp
    #   Allows grantee to read the object ACL.
    #
    # @option params [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    #
    # @option params [required, String] :key
    #
    # @option params [Hash<String,String>] :metadata
    #   A map of metadata to store with the object in S3.
    #
    # @option params [String] :metadata_directive
    #   Specifies whether the metadata is copied from the source object or
    #   replaced with metadata provided in the request.
    #
    # @option params [String] :tagging_directive
    #   Specifies whether the object tag-set are copied from the source object
    #   or replaced with tag-set provided in the request.
    #
    # @option params [String] :server_side_encryption
    #   The Server-side encryption algorithm used when storing this object in
    #   S3 (e.g., AES256, aws:kms).
    #
    # @option params [String] :storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    #
    # @option params [String] :website_redirect_location
    #   If the bucket is configured as a website, redirects requests for this
    #   object to another object in the same bucket or to an external URL.
    #   Amazon S3 stores the value of this header in the object metadata.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET and
    #   PUT requests for an object protected by AWS KMS will fail if not made
    #   via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    #
    # @option params [String] :copy_source_sse_customer_algorithm
    #   Specifies the algorithm to use when decrypting the source object
    #   (e.g., AES256).
    #
    # @option params [String] :copy_source_sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use to
    #   decrypt the source object. The encryption key provided in this header
    #   must be one that was used when the source object was created.
    #
    # @option params [String] :copy_source_sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @option params [String] :tagging
    #   The tag-set for the object destination object this value must be used
    #   in conjunction with the TaggingDirective. The tag-set must be encoded
    #   as URL Query parameters
    #
    # @return [Types::CopyObjectOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::CopyObjectOutput#copy_object_result #copy_object_result} => Types::CopyObjectResult
    #   * {Types::CopyObjectOutput#expiration #expiration} => String
    #   * {Types::CopyObjectOutput#copy_source_version_id #copy_source_version_id} => String
    #   * {Types::CopyObjectOutput#version_id #version_id} => String
    #   * {Types::CopyObjectOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::CopyObjectOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::CopyObjectOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::CopyObjectOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::CopyObjectOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To copy an object
    #
    #   # The following example copies an object from one bucket to another.
    #
    #   resp = client.copy_object({
    #     bucket: "destinationbucket", 
    #     copy_source: "/sourcebucket/HappyFacejpg", 
    #     key: "HappyFaceCopyjpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     copy_object_result: {
    #       etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #       last_modified: Time.parse("2016-12-15T17:38:53.000Z"), 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.copy_object({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #     bucket: "BucketName", # required
    #     cache_control: "CacheControl",
    #     content_disposition: "ContentDisposition",
    #     content_encoding: "ContentEncoding",
    #     content_language: "ContentLanguage",
    #     content_type: "ContentType",
    #     copy_source: "CopySource", # required
    #     copy_source_if_match: "CopySourceIfMatch",
    #     copy_source_if_modified_since: Time.now,
    #     copy_source_if_none_match: "CopySourceIfNoneMatch",
    #     copy_source_if_unmodified_since: Time.now,
    #     expires: Time.now,
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write_acp: "GrantWriteACP",
    #     key: "ObjectKey", # required
    #     metadata: {
    #       "MetadataKey" => "MetadataValue",
    #     },
    #     metadata_directive: "COPY", # accepts COPY, REPLACE
    #     tagging_directive: "COPY", # accepts COPY, REPLACE
    #     server_side_encryption: "AES256", # accepts AES256, aws:kms
    #     storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #     website_redirect_location: "WebsiteRedirectLocation",
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     ssekms_key_id: "SSEKMSKeyId",
    #     copy_source_sse_customer_algorithm: "CopySourceSSECustomerAlgorithm",
    #     copy_source_sse_customer_key: "CopySourceSSECustomerKey",
    #     copy_source_sse_customer_key_md5: "CopySourceSSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #     tagging: "TaggingHeader",
    #   })
    #
    # @example Response structure
    #
    #   resp.copy_object_result.etag #=> String
    #   resp.copy_object_result.last_modified #=> Time
    #   resp.expiration #=> String
    #   resp.copy_source_version_id #=> String
    #   resp.version_id #=> String
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CopyObject AWS API Documentation
    #
    # @overload copy_object(params = {})
    # @param [Hash] params ({})
    def copy_object(params = {}, options = {})
      req = build_request(:copy_object, params)
      req.send_request(options)
    end

    # Creates a new bucket.
    #
    # @option params [String] :acl
    #   The canned ACL to apply to the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [Types::CreateBucketConfiguration] :create_bucket_configuration
    #
    # @option params [String] :grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions on
    #   the bucket.
    #
    # @option params [String] :grant_read
    #   Allows grantee to list the objects in the bucket.
    #
    # @option params [String] :grant_read_acp
    #   Allows grantee to read the bucket ACL.
    #
    # @option params [String] :grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    #
    # @option params [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    #
    # @return [Types::CreateBucketOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::CreateBucketOutput#location #location} => String
    #
    #
    # @example Example: To create a bucket in a specific region
    #
    #   # The following example creates a bucket. The request specifies an AWS region where to create the bucket.
    #
    #   resp = client.create_bucket({
    #     bucket: "examplebucket", 
    #     create_bucket_configuration: {
    #       location_constraint: "eu-west-1", 
    #     }, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     location: "http://examplebucket.s3.amazonaws.com/", 
    #   }
    #
    # @example Example: To create a bucket 
    #
    #   # The following example creates a bucket.
    #
    #   resp = client.create_bucket({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     location: "/examplebucket", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.create_bucket({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #     bucket: "BucketName", # required
    #     create_bucket_configuration: {
    #       location_constraint: "EU", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
    #     },
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write: "GrantWrite",
    #     grant_write_acp: "GrantWriteACP",
    #   })
    #
    # @example Response structure
    #
    #   resp.location #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateBucket AWS API Documentation
    #
    # @overload create_bucket(params = {})
    # @param [Hash] params ({})
    def create_bucket(params = {}, options = {})
      req = build_request(:create_bucket, params)
      req.send_request(options)
    end

    # Initiates a multipart upload and returns an upload ID.
    #
    # **Note:** After you initiate multipart upload and upload one or more
    # parts, you must either complete or abort multipart upload in order to
    # stop getting charged for storage of the uploaded parts. Only after you
    # either complete or abort multipart upload, Amazon S3 frees up the
    # parts storage and stops charging you for the parts storage.
    #
    # @option params [String] :acl
    #   The canned ACL to apply to the object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :cache_control
    #   Specifies caching behavior along the request/reply chain.
    #
    # @option params [String] :content_disposition
    #   Specifies presentational information for the object.
    #
    # @option params [String] :content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the media-type
    #   referenced by the Content-Type header field.
    #
    # @option params [String] :content_language
    #   The language the content is in.
    #
    # @option params [String] :content_type
    #   A standard MIME type describing the format of the object data.
    #
    # @option params [Time,DateTime,Date,Integer,String] :expires
    #   The date and time at which the object is no longer cacheable.
    #
    # @option params [String] :grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    #
    # @option params [String] :grant_read
    #   Allows grantee to read the object data and its metadata.
    #
    # @option params [String] :grant_read_acp
    #   Allows grantee to read the object ACL.
    #
    # @option params [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    #
    # @option params [required, String] :key
    #
    # @option params [Hash<String,String>] :metadata
    #   A map of metadata to store with the object in S3.
    #
    # @option params [String] :server_side_encryption
    #   The Server-side encryption algorithm used when storing this object in
    #   S3 (e.g., AES256, aws:kms).
    #
    # @option params [String] :storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    #
    # @option params [String] :website_redirect_location
    #   If the bucket is configured as a website, redirects requests for this
    #   object to another object in the same bucket or to an external URL.
    #   Amazon S3 stores the value of this header in the object metadata.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET and
    #   PUT requests for an object protected by AWS KMS will fail if not made
    #   via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @option params [String] :tagging
    #   The tag-set for the object. The tag-set must be encoded as URL Query
    #   parameters
    #
    # @return [Types::CreateMultipartUploadOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::CreateMultipartUploadOutput#abort_date #abort_date} => Time
    #   * {Types::CreateMultipartUploadOutput#abort_rule_id #abort_rule_id} => String
    #   * {Types::CreateMultipartUploadOutput#bucket #bucket} => String
    #   * {Types::CreateMultipartUploadOutput#key #key} => String
    #   * {Types::CreateMultipartUploadOutput#upload_id #upload_id} => String
    #   * {Types::CreateMultipartUploadOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::CreateMultipartUploadOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::CreateMultipartUploadOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::CreateMultipartUploadOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::CreateMultipartUploadOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To initiate a multipart upload
    #
    #   # The following example initiates a multipart upload.
    #
    #   resp = client.create_multipart_upload({
    #     bucket: "examplebucket", 
    #     key: "largeobject", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     bucket: "examplebucket", 
    #     key: "largeobject", 
    #     upload_id: "ibZBv_75gd9r8lH_gqXatLdxMVpAlj6ZQjEs.OwyF3953YdwbcQnMA2BLGn8Lx12fQNICtMw5KyteFeHw.Sjng--", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.create_multipart_upload({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #     bucket: "BucketName", # required
    #     cache_control: "CacheControl",
    #     content_disposition: "ContentDisposition",
    #     content_encoding: "ContentEncoding",
    #     content_language: "ContentLanguage",
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
    #
    # @example Response structure
    #
    #   resp.abort_date #=> Time
    #   resp.abort_rule_id #=> String
    #   resp.bucket #=> String
    #   resp.key #=> String
    #   resp.upload_id #=> String
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateMultipartUpload AWS API Documentation
    #
    # @overload create_multipart_upload(params = {})
    # @param [Hash] params ({})
    def create_multipart_upload(params = {}, options = {})
      req = build_request(:create_multipart_upload, params)
      req.send_request(options)
    end

    # Deletes the bucket. All objects (including all object versions and
    # Delete Markers) in the bucket must be deleted before the bucket itself
    # can be deleted.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete a bucket
    #
    #   # The following example deletes the specified bucket.
    #
    #   resp = client.delete_bucket({
    #     bucket: "forrandall2", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucket AWS API Documentation
    #
    # @overload delete_bucket(params = {})
    # @param [Hash] params ({})
    def delete_bucket(params = {}, options = {})
      req = build_request(:delete_bucket, params)
      req.send_request(options)
    end

    # Deletes an analytics configuration for the bucket (specified by the
    # analytics configuration ID).
    #
    # @option params [required, String] :bucket
    #   The name of the bucket from which an analytics configuration is
    #   deleted.
    #
    # @option params [required, String] :id
    #   The identifier used to represent an analytics configuration.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_analytics_configuration({
    #     bucket: "BucketName", # required
    #     id: "AnalyticsId", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketAnalyticsConfiguration AWS API Documentation
    #
    # @overload delete_bucket_analytics_configuration(params = {})
    # @param [Hash] params ({})
    def delete_bucket_analytics_configuration(params = {}, options = {})
      req = build_request(:delete_bucket_analytics_configuration, params)
      req.send_request(options)
    end

    # Deletes the cors configuration information set for the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete cors configuration on a bucket.
    #
    #   # The following example deletes CORS configuration on a bucket.
    #
    #   resp = client.delete_bucket_cors({
    #     bucket: "examplebucket", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_cors({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketCors AWS API Documentation
    #
    # @overload delete_bucket_cors(params = {})
    # @param [Hash] params ({})
    def delete_bucket_cors(params = {}, options = {})
      req = build_request(:delete_bucket_cors, params)
      req.send_request(options)
    end

    # Deletes the server-side encryption configuration from the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the server-side encryption
    #   configuration to delete.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_encryption({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketEncryption AWS API Documentation
    #
    # @overload delete_bucket_encryption(params = {})
    # @param [Hash] params ({})
    def delete_bucket_encryption(params = {}, options = {})
      req = build_request(:delete_bucket_encryption, params)
      req.send_request(options)
    end

    # Deletes an inventory configuration (identified by the inventory ID)
    # from the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the inventory configuration to
    #   delete.
    #
    # @option params [required, String] :id
    #   The ID used to identify the inventory configuration.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_inventory_configuration({
    #     bucket: "BucketName", # required
    #     id: "InventoryId", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketInventoryConfiguration AWS API Documentation
    #
    # @overload delete_bucket_inventory_configuration(params = {})
    # @param [Hash] params ({})
    def delete_bucket_inventory_configuration(params = {}, options = {})
      req = build_request(:delete_bucket_inventory_configuration, params)
      req.send_request(options)
    end

    # Deletes the lifecycle configuration from the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete lifecycle configuration on a bucket.
    #
    #   # The following example deletes lifecycle configuration on a bucket.
    #
    #   resp = client.delete_bucket_lifecycle({
    #     bucket: "examplebucket", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_lifecycle({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketLifecycle AWS API Documentation
    #
    # @overload delete_bucket_lifecycle(params = {})
    # @param [Hash] params ({})
    def delete_bucket_lifecycle(params = {}, options = {})
      req = build_request(:delete_bucket_lifecycle, params)
      req.send_request(options)
    end

    # Deletes a metrics configuration (specified by the metrics
    # configuration ID) from the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the metrics configuration to delete.
    #
    # @option params [required, String] :id
    #   The ID used to identify the metrics configuration.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_metrics_configuration({
    #     bucket: "BucketName", # required
    #     id: "MetricsId", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketMetricsConfiguration AWS API Documentation
    #
    # @overload delete_bucket_metrics_configuration(params = {})
    # @param [Hash] params ({})
    def delete_bucket_metrics_configuration(params = {}, options = {})
      req = build_request(:delete_bucket_metrics_configuration, params)
      req.send_request(options)
    end

    # Deletes the policy from the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete bucket policy
    #
    #   # The following example deletes bucket policy on the specified bucket.
    #
    #   resp = client.delete_bucket_policy({
    #     bucket: "examplebucket", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_policy({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketPolicy AWS API Documentation
    #
    # @overload delete_bucket_policy(params = {})
    # @param [Hash] params ({})
    def delete_bucket_policy(params = {}, options = {})
      req = build_request(:delete_bucket_policy, params)
      req.send_request(options)
    end

    # Deletes the replication configuration from the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete bucket replication configuration
    #
    #   # The following example deletes replication configuration set on bucket.
    #
    #   resp = client.delete_bucket_replication({
    #     bucket: "example", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_replication({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketReplication AWS API Documentation
    #
    # @overload delete_bucket_replication(params = {})
    # @param [Hash] params ({})
    def delete_bucket_replication(params = {}, options = {})
      req = build_request(:delete_bucket_replication, params)
      req.send_request(options)
    end

    # Deletes the tags from the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete bucket tags
    #
    #   # The following example deletes bucket tags.
    #
    #   resp = client.delete_bucket_tagging({
    #     bucket: "examplebucket", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_tagging({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketTagging AWS API Documentation
    #
    # @overload delete_bucket_tagging(params = {})
    # @param [Hash] params ({})
    def delete_bucket_tagging(params = {}, options = {})
      req = build_request(:delete_bucket_tagging, params)
      req.send_request(options)
    end

    # This operation removes the website configuration from the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To delete bucket website configuration
    #
    #   # The following example deletes bucket website configuration.
    #
    #   resp = client.delete_bucket_website({
    #     bucket: "examplebucket", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_bucket_website({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketWebsite AWS API Documentation
    #
    # @overload delete_bucket_website(params = {})
    # @param [Hash] params ({})
    def delete_bucket_website(params = {}, options = {})
      req = build_request(:delete_bucket_website, params)
      req.send_request(options)
    end

    # Removes the null version (if there is one) of an object and inserts a
    # delete marker, which becomes the latest version of the object. If
    # there isn't a null version, Amazon S3 does not remove any objects.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication device.
    #
    # @option params [String] :version_id
    #   VersionId used to reference a specific version of the object.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::DeleteObjectOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::DeleteObjectOutput#delete_marker #delete_marker} => Boolean
    #   * {Types::DeleteObjectOutput#version_id #version_id} => String
    #   * {Types::DeleteObjectOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To delete an object (from a non-versioned bucket)
    #
    #   # The following example deletes an object from a non-versioned bucket.
    #
    #   resp = client.delete_object({
    #     bucket: "ExampleBucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    # @example Example: To delete an object
    #
    #   # The following example deletes an object from an S3 bucket.
    #
    #   resp = client.delete_object({
    #     bucket: "examplebucket", 
    #     key: "objectkey.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_object({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     mfa: "MFA",
    #     version_id: "ObjectVersionId",
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.delete_marker #=> Boolean
    #   resp.version_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObject AWS API Documentation
    #
    # @overload delete_object(params = {})
    # @param [Hash] params ({})
    def delete_object(params = {}, options = {})
      req = build_request(:delete_object, params)
      req.send_request(options)
    end

    # Removes the tag-set from an existing object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :version_id
    #   The versionId of the object that the tag-set will be removed from.
    #
    # @return [Types::DeleteObjectTaggingOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::DeleteObjectTaggingOutput#version_id #version_id} => String
    #
    #
    # @example Example: To remove tag set from an object version
    #
    #   # The following example removes tag set associated with the specified object version. The request specifies both the
    #   # object key and object version.
    #
    #   resp = client.delete_object_tagging({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #     version_id: "ydlaNkwWm0SfKJR.T1b1fIdPRbldTYRI", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     version_id: "ydlaNkwWm0SfKJR.T1b1fIdPRbldTYRI", 
    #   }
    #
    # @example Example: To remove tag set from an object
    #
    #   # The following example removes tag set associated with the specified object. If the bucket is versioning enabled, the
    #   # operation removes tag set from the latest object version.
    #
    #   resp = client.delete_object_tagging({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     version_id: "null", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_object_tagging({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     version_id: "ObjectVersionId",
    #   })
    #
    # @example Response structure
    #
    #   resp.version_id #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectTagging AWS API Documentation
    #
    # @overload delete_object_tagging(params = {})
    # @param [Hash] params ({})
    def delete_object_tagging(params = {}, options = {})
      req = build_request(:delete_object_tagging, params)
      req.send_request(options)
    end

    # This operation enables you to delete multiple objects from a bucket
    # using a single HTTP request. You may specify up to 1000 keys.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, Types::Delete] :delete
    #
    # @option params [String] :mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication device.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::DeleteObjectsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::DeleteObjectsOutput#deleted #deleted} => Array&lt;Types::DeletedObject&gt;
    #   * {Types::DeleteObjectsOutput#request_charged #request_charged} => String
    #   * {Types::DeleteObjectsOutput#errors #errors} => Array&lt;Types::Error&gt;
    #
    #
    # @example Example: To delete multiple object versions from a versioned bucket
    #
    #   # The following example deletes objects from a bucket. The request specifies object versions. S3 deletes specific object
    #   # versions and returns the key and versions of deleted objects in the response.
    #
    #   resp = client.delete_objects({
    #     bucket: "examplebucket", 
    #     delete: {
    #       objects: [
    #         {
    #           key: "HappyFace.jpg", 
    #           version_id: "2LWg7lQLnY41.maGB5Z6SWW.dcq0vx7b", 
    #         }, 
    #         {
    #           key: "HappyFace.jpg", 
    #           version_id: "yoz3HB.ZhCS_tKVEmIOr7qYyyAaZSKVd", 
    #         }, 
    #       ], 
    #       quiet: false, 
    #     }, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     deleted: [
    #       {
    #         key: "HappyFace.jpg", 
    #         version_id: "yoz3HB.ZhCS_tKVEmIOr7qYyyAaZSKVd", 
    #       }, 
    #       {
    #         key: "HappyFace.jpg", 
    #         version_id: "2LWg7lQLnY41.maGB5Z6SWW.dcq0vx7b", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Example: To delete multiple objects from a versioned bucket
    #
    #   # The following example deletes objects from a bucket. The bucket is versioned, and the request does not specify the
    #   # object version to delete. In this case, all versions remain in the bucket and S3 adds a delete marker.
    #
    #   resp = client.delete_objects({
    #     bucket: "examplebucket", 
    #     delete: {
    #       objects: [
    #         {
    #           key: "objectkey1", 
    #         }, 
    #         {
    #           key: "objectkey2", 
    #         }, 
    #       ], 
    #       quiet: false, 
    #     }, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     deleted: [
    #       {
    #         delete_marker: true, 
    #         delete_marker_version_id: "A._w1z6EFiCF5uhtQMDal9JDkID9tQ7F", 
    #         key: "objectkey1", 
    #       }, 
    #       {
    #         delete_marker: true, 
    #         delete_marker_version_id: "iOd_ORxhkKe_e8G8_oSGxt2PjsCZKlkt", 
    #         key: "objectkey2", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_objects({
    #     bucket: "BucketName", # required
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
    #
    # @example Response structure
    #
    #   resp.deleted #=> Array
    #   resp.deleted[0].key #=> String
    #   resp.deleted[0].version_id #=> String
    #   resp.deleted[0].delete_marker #=> Boolean
    #   resp.deleted[0].delete_marker_version_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #   resp.errors #=> Array
    #   resp.errors[0].key #=> String
    #   resp.errors[0].version_id #=> String
    #   resp.errors[0].code #=> String
    #   resp.errors[0].message #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjects AWS API Documentation
    #
    # @overload delete_objects(params = {})
    # @param [Hash] params ({})
    def delete_objects(params = {}, options = {})
      req = build_request(:delete_objects, params)
      req.send_request(options)
    end

    # Returns the accelerate configuration of a bucket.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket for which the accelerate configuration is
    #   retrieved.
    #
    # @return [Types::GetBucketAccelerateConfigurationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketAccelerateConfigurationOutput#status #status} => String
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_accelerate_configuration({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.status #=> String, one of "Enabled", "Suspended"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAccelerateConfiguration AWS API Documentation
    #
    # @overload get_bucket_accelerate_configuration(params = {})
    # @param [Hash] params ({})
    def get_bucket_accelerate_configuration(params = {}, options = {})
      req = build_request(:get_bucket_accelerate_configuration, params)
      req.send_request(options)
    end

    # Gets the access control policy for the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketAclOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketAclOutput#owner #owner} => Types::Owner
    #   * {Types::GetBucketAclOutput#grants #grants} => Array&lt;Types::Grant&gt;
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_acl({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.owner.display_name #=> String
    #   resp.owner.id #=> String
    #   resp.grants #=> Array
    #   resp.grants[0].grantee.display_name #=> String
    #   resp.grants[0].grantee.email_address #=> String
    #   resp.grants[0].grantee.id #=> String
    #   resp.grants[0].grantee.type #=> String, one of "CanonicalUser", "AmazonCustomerByEmail", "Group"
    #   resp.grants[0].grantee.uri #=> String
    #   resp.grants[0].permission #=> String, one of "FULL_CONTROL", "WRITE", "WRITE_ACP", "READ", "READ_ACP"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAcl AWS API Documentation
    #
    # @overload get_bucket_acl(params = {})
    # @param [Hash] params ({})
    def get_bucket_acl(params = {}, options = {})
      req = build_request(:get_bucket_acl, params)
      req.send_request(options)
    end

    # Gets an analytics configuration for the bucket (specified by the
    # analytics configuration ID).
    #
    # @option params [required, String] :bucket
    #   The name of the bucket from which an analytics configuration is
    #   retrieved.
    #
    # @option params [required, String] :id
    #   The identifier used to represent an analytics configuration.
    #
    # @return [Types::GetBucketAnalyticsConfigurationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketAnalyticsConfigurationOutput#analytics_configuration #analytics_configuration} => Types::AnalyticsConfiguration
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_analytics_configuration({
    #     bucket: "BucketName", # required
    #     id: "AnalyticsId", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.analytics_configuration.id #=> String
    #   resp.analytics_configuration.filter.prefix #=> String
    #   resp.analytics_configuration.filter.tag.key #=> String
    #   resp.analytics_configuration.filter.tag.value #=> String
    #   resp.analytics_configuration.filter.and.prefix #=> String
    #   resp.analytics_configuration.filter.and.tags #=> Array
    #   resp.analytics_configuration.filter.and.tags[0].key #=> String
    #   resp.analytics_configuration.filter.and.tags[0].value #=> String
    #   resp.analytics_configuration.storage_class_analysis.data_export.output_schema_version #=> String, one of "V_1"
    #   resp.analytics_configuration.storage_class_analysis.data_export.destination.s3_bucket_destination.format #=> String, one of "CSV"
    #   resp.analytics_configuration.storage_class_analysis.data_export.destination.s3_bucket_destination.bucket_account_id #=> String
    #   resp.analytics_configuration.storage_class_analysis.data_export.destination.s3_bucket_destination.bucket #=> String
    #   resp.analytics_configuration.storage_class_analysis.data_export.destination.s3_bucket_destination.prefix #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAnalyticsConfiguration AWS API Documentation
    #
    # @overload get_bucket_analytics_configuration(params = {})
    # @param [Hash] params ({})
    def get_bucket_analytics_configuration(params = {}, options = {})
      req = build_request(:get_bucket_analytics_configuration, params)
      req.send_request(options)
    end

    # Returns the cors configuration for the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketCorsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketCorsOutput#cors_rules #cors_rules} => Array&lt;Types::CORSRule&gt;
    #
    #
    # @example Example: To get cors configuration set on a bucket
    #
    #   # The following example returns cross-origin resource sharing (CORS) configuration set on a bucket.
    #
    #   resp = client.get_bucket_cors({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     cors_rules: [
    #       {
    #         allowed_headers: [
    #           "Authorization", 
    #         ], 
    #         allowed_methods: [
    #           "GET", 
    #         ], 
    #         allowed_origins: [
    #           "*", 
    #         ], 
    #         max_age_seconds: 3000, 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_cors({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.cors_rules #=> Array
    #   resp.cors_rules[0].allowed_headers #=> Array
    #   resp.cors_rules[0].allowed_headers[0] #=> String
    #   resp.cors_rules[0].allowed_methods #=> Array
    #   resp.cors_rules[0].allowed_methods[0] #=> String
    #   resp.cors_rules[0].allowed_origins #=> Array
    #   resp.cors_rules[0].allowed_origins[0] #=> String
    #   resp.cors_rules[0].expose_headers #=> Array
    #   resp.cors_rules[0].expose_headers[0] #=> String
    #   resp.cors_rules[0].max_age_seconds #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketCors AWS API Documentation
    #
    # @overload get_bucket_cors(params = {})
    # @param [Hash] params ({})
    def get_bucket_cors(params = {}, options = {})
      req = build_request(:get_bucket_cors, params)
      req.send_request(options)
    end

    # Returns the server-side encryption configuration of a bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket from which the server-side encryption
    #   configuration is retrieved.
    #
    # @return [Types::GetBucketEncryptionOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketEncryptionOutput#server_side_encryption_configuration #server_side_encryption_configuration} => Types::ServerSideEncryptionConfiguration
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_encryption({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.server_side_encryption_configuration.rules #=> Array
    #   resp.server_side_encryption_configuration.rules[0].apply_server_side_encryption_by_default.sse_algorithm #=> String, one of "AES256", "aws:kms"
    #   resp.server_side_encryption_configuration.rules[0].apply_server_side_encryption_by_default.kms_master_key_id #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketEncryption AWS API Documentation
    #
    # @overload get_bucket_encryption(params = {})
    # @param [Hash] params ({})
    def get_bucket_encryption(params = {}, options = {})
      req = build_request(:get_bucket_encryption, params)
      req.send_request(options)
    end

    # Returns an inventory configuration (identified by the inventory ID)
    # from the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the inventory configuration to
    #   retrieve.
    #
    # @option params [required, String] :id
    #   The ID used to identify the inventory configuration.
    #
    # @return [Types::GetBucketInventoryConfigurationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketInventoryConfigurationOutput#inventory_configuration #inventory_configuration} => Types::InventoryConfiguration
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_inventory_configuration({
    #     bucket: "BucketName", # required
    #     id: "InventoryId", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.inventory_configuration.destination.s3_bucket_destination.account_id #=> String
    #   resp.inventory_configuration.destination.s3_bucket_destination.bucket #=> String
    #   resp.inventory_configuration.destination.s3_bucket_destination.format #=> String, one of "CSV", "ORC"
    #   resp.inventory_configuration.destination.s3_bucket_destination.prefix #=> String
    #   resp.inventory_configuration.destination.s3_bucket_destination.encryption.ssekms.key_id #=> String
    #   resp.inventory_configuration.is_enabled #=> Boolean
    #   resp.inventory_configuration.filter.prefix #=> String
    #   resp.inventory_configuration.id #=> String
    #   resp.inventory_configuration.included_object_versions #=> String, one of "All", "Current"
    #   resp.inventory_configuration.optional_fields #=> Array
    #   resp.inventory_configuration.optional_fields[0] #=> String, one of "Size", "LastModifiedDate", "StorageClass", "ETag", "IsMultipartUploaded", "ReplicationStatus", "EncryptionStatus"
    #   resp.inventory_configuration.schedule.frequency #=> String, one of "Daily", "Weekly"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketInventoryConfiguration AWS API Documentation
    #
    # @overload get_bucket_inventory_configuration(params = {})
    # @param [Hash] params ({})
    def get_bucket_inventory_configuration(params = {}, options = {})
      req = build_request(:get_bucket_inventory_configuration, params)
      req.send_request(options)
    end

    # Deprecated, see the GetBucketLifecycleConfiguration operation.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketLifecycleOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketLifecycleOutput#rules #rules} => Array&lt;Types::Rule&gt;
    #
    #
    # @example Example: To get a bucket acl
    #
    #   # The following example gets ACL on the specified bucket.
    #
    #   resp = client.get_bucket_lifecycle({
    #     bucket: "acl1", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     rules: [
    #       {
    #         expiration: {
    #           days: 1, 
    #         }, 
    #         id: "delete logs", 
    #         prefix: "123/", 
    #         status: "Enabled", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_lifecycle({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.rules #=> Array
    #   resp.rules[0].expiration.date #=> Time
    #   resp.rules[0].expiration.days #=> Integer
    #   resp.rules[0].expiration.expired_object_delete_marker #=> Boolean
    #   resp.rules[0].id #=> String
    #   resp.rules[0].prefix #=> String
    #   resp.rules[0].status #=> String, one of "Enabled", "Disabled"
    #   resp.rules[0].transition.date #=> Time
    #   resp.rules[0].transition.days #=> Integer
    #   resp.rules[0].transition.storage_class #=> String, one of "GLACIER", "STANDARD_IA", "ONEZONE_IA"
    #   resp.rules[0].noncurrent_version_transition.noncurrent_days #=> Integer
    #   resp.rules[0].noncurrent_version_transition.storage_class #=> String, one of "GLACIER", "STANDARD_IA", "ONEZONE_IA"
    #   resp.rules[0].noncurrent_version_expiration.noncurrent_days #=> Integer
    #   resp.rules[0].abort_incomplete_multipart_upload.days_after_initiation #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLifecycle AWS API Documentation
    #
    # @overload get_bucket_lifecycle(params = {})
    # @param [Hash] params ({})
    def get_bucket_lifecycle(params = {}, options = {})
      req = build_request(:get_bucket_lifecycle, params)
      req.send_request(options)
    end

    # Returns the lifecycle configuration information set on the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketLifecycleConfigurationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketLifecycleConfigurationOutput#rules #rules} => Array&lt;Types::LifecycleRule&gt;
    #
    #
    # @example Example: To get lifecycle configuration on a bucket
    #
    #   # The following example retrieves lifecycle configuration on set on a bucket. 
    #
    #   resp = client.get_bucket_lifecycle_configuration({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     rules: [
    #       {
    #         id: "Rule for TaxDocs/", 
    #         prefix: "TaxDocs", 
    #         status: "Enabled", 
    #         transitions: [
    #           {
    #             days: 365, 
    #             storage_class: "STANDARD_IA", 
    #           }, 
    #         ], 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_lifecycle_configuration({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.rules #=> Array
    #   resp.rules[0].expiration.date #=> Time
    #   resp.rules[0].expiration.days #=> Integer
    #   resp.rules[0].expiration.expired_object_delete_marker #=> Boolean
    #   resp.rules[0].id #=> String
    #   resp.rules[0].prefix #=> String
    #   resp.rules[0].filter.prefix #=> String
    #   resp.rules[0].filter.tag.key #=> String
    #   resp.rules[0].filter.tag.value #=> String
    #   resp.rules[0].filter.and.prefix #=> String
    #   resp.rules[0].filter.and.tags #=> Array
    #   resp.rules[0].filter.and.tags[0].key #=> String
    #   resp.rules[0].filter.and.tags[0].value #=> String
    #   resp.rules[0].status #=> String, one of "Enabled", "Disabled"
    #   resp.rules[0].transitions #=> Array
    #   resp.rules[0].transitions[0].date #=> Time
    #   resp.rules[0].transitions[0].days #=> Integer
    #   resp.rules[0].transitions[0].storage_class #=> String, one of "GLACIER", "STANDARD_IA", "ONEZONE_IA"
    #   resp.rules[0].noncurrent_version_transitions #=> Array
    #   resp.rules[0].noncurrent_version_transitions[0].noncurrent_days #=> Integer
    #   resp.rules[0].noncurrent_version_transitions[0].storage_class #=> String, one of "GLACIER", "STANDARD_IA", "ONEZONE_IA"
    #   resp.rules[0].noncurrent_version_expiration.noncurrent_days #=> Integer
    #   resp.rules[0].abort_incomplete_multipart_upload.days_after_initiation #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLifecycleConfiguration AWS API Documentation
    #
    # @overload get_bucket_lifecycle_configuration(params = {})
    # @param [Hash] params ({})
    def get_bucket_lifecycle_configuration(params = {}, options = {})
      req = build_request(:get_bucket_lifecycle_configuration, params)
      req.send_request(options)
    end

    # Returns the region the bucket resides in.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketLocationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketLocationOutput#location_constraint #location_constraint} => String
    #
    #
    # @example Example: To get bucket location
    #
    #   # The following example returns bucket location.
    #
    #   resp = client.get_bucket_location({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     location_constraint: "us-west-2", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_location({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.location_constraint #=> String, one of "EU", "eu-west-1", "us-west-1", "us-west-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "sa-east-1", "cn-north-1", "eu-central-1"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLocation AWS API Documentation
    #
    # @overload get_bucket_location(params = {})
    # @param [Hash] params ({})
    def get_bucket_location(params = {}, options = {})
      req = build_request(:get_bucket_location, params)
      req.send_request(options)
    end

    # Returns the logging status of a bucket and the permissions users have
    # to view and modify that status. To use GET, you must be the bucket
    # owner.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketLoggingOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketLoggingOutput#logging_enabled #logging_enabled} => Types::LoggingEnabled
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_logging({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.logging_enabled.target_bucket #=> String
    #   resp.logging_enabled.target_grants #=> Array
    #   resp.logging_enabled.target_grants[0].grantee.display_name #=> String
    #   resp.logging_enabled.target_grants[0].grantee.email_address #=> String
    #   resp.logging_enabled.target_grants[0].grantee.id #=> String
    #   resp.logging_enabled.target_grants[0].grantee.type #=> String, one of "CanonicalUser", "AmazonCustomerByEmail", "Group"
    #   resp.logging_enabled.target_grants[0].grantee.uri #=> String
    #   resp.logging_enabled.target_grants[0].permission #=> String, one of "FULL_CONTROL", "READ", "WRITE"
    #   resp.logging_enabled.target_prefix #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLogging AWS API Documentation
    #
    # @overload get_bucket_logging(params = {})
    # @param [Hash] params ({})
    def get_bucket_logging(params = {}, options = {})
      req = build_request(:get_bucket_logging, params)
      req.send_request(options)
    end

    # Gets a metrics configuration (specified by the metrics configuration
    # ID) from the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the metrics configuration to
    #   retrieve.
    #
    # @option params [required, String] :id
    #   The ID used to identify the metrics configuration.
    #
    # @return [Types::GetBucketMetricsConfigurationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketMetricsConfigurationOutput#metrics_configuration #metrics_configuration} => Types::MetricsConfiguration
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_metrics_configuration({
    #     bucket: "BucketName", # required
    #     id: "MetricsId", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.metrics_configuration.id #=> String
    #   resp.metrics_configuration.filter.prefix #=> String
    #   resp.metrics_configuration.filter.tag.key #=> String
    #   resp.metrics_configuration.filter.tag.value #=> String
    #   resp.metrics_configuration.filter.and.prefix #=> String
    #   resp.metrics_configuration.filter.and.tags #=> Array
    #   resp.metrics_configuration.filter.and.tags[0].key #=> String
    #   resp.metrics_configuration.filter.and.tags[0].value #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketMetricsConfiguration AWS API Documentation
    #
    # @overload get_bucket_metrics_configuration(params = {})
    # @param [Hash] params ({})
    def get_bucket_metrics_configuration(params = {}, options = {})
      req = build_request(:get_bucket_metrics_configuration, params)
      req.send_request(options)
    end

    # Deprecated, see the GetBucketNotificationConfiguration operation.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket to get the notification configuration for.
    #
    # @return [Types::NotificationConfigurationDeprecated] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::NotificationConfigurationDeprecated#topic_configuration #topic_configuration} => Types::TopicConfigurationDeprecated
    #   * {Types::NotificationConfigurationDeprecated#queue_configuration #queue_configuration} => Types::QueueConfigurationDeprecated
    #   * {Types::NotificationConfigurationDeprecated#cloud_function_configuration #cloud_function_configuration} => Types::CloudFunctionConfiguration
    #
    #
    # @example Example: To get notification configuration set on a bucket
    #
    #   # The following example returns notification configuration set on a bucket.
    #
    #   resp = client.get_bucket_notification({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     queue_configuration: {
    #       event: "s3:ObjectCreated:Put", 
    #       events: [
    #         "s3:ObjectCreated:Put", 
    #       ], 
    #       id: "MDQ2OGQ4NDEtOTBmNi00YTM4LTk0NzYtZDIwN2I3NWQ1NjIx", 
    #       queue: "arn:aws:sqs:us-east-1:acct-id:S3ObjectCreatedEventQueue", 
    #     }, 
    #     topic_configuration: {
    #       event: "s3:ObjectCreated:Copy", 
    #       events: [
    #         "s3:ObjectCreated:Copy", 
    #       ], 
    #       id: "YTVkMWEzZGUtNTY1NS00ZmE2LWJjYjktMmRlY2QwODFkNTJi", 
    #       topic: "arn:aws:sns:us-east-1:acct-id:S3ObjectCreatedEventTopic", 
    #     }, 
    #   }
    #
    # @example Example: To get notification configuration set on a bucket
    #
    #   # The following example returns notification configuration set on a bucket.
    #
    #   resp = client.get_bucket_notification({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     queue_configuration: {
    #       event: "s3:ObjectCreated:Put", 
    #       events: [
    #         "s3:ObjectCreated:Put", 
    #       ], 
    #       id: "MDQ2OGQ4NDEtOTBmNi00YTM4LTk0NzYtZDIwN2I3NWQ1NjIx", 
    #       queue: "arn:aws:sqs:us-east-1:acct-id:S3ObjectCreatedEventQueue", 
    #     }, 
    #     topic_configuration: {
    #       event: "s3:ObjectCreated:Copy", 
    #       events: [
    #         "s3:ObjectCreated:Copy", 
    #       ], 
    #       id: "YTVkMWEzZGUtNTY1NS00ZmE2LWJjYjktMmRlY2QwODFkNTJi", 
    #       topic: "arn:aws:sns:us-east-1:acct-id:S3ObjectCreatedEventTopic", 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_notification({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.topic_configuration.id #=> String
    #   resp.topic_configuration.events #=> Array
    #   resp.topic_configuration.events[0] #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.topic_configuration.event #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.topic_configuration.topic #=> String
    #   resp.queue_configuration.id #=> String
    #   resp.queue_configuration.event #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.queue_configuration.events #=> Array
    #   resp.queue_configuration.events[0] #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.queue_configuration.queue #=> String
    #   resp.cloud_function_configuration.id #=> String
    #   resp.cloud_function_configuration.event #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.cloud_function_configuration.events #=> Array
    #   resp.cloud_function_configuration.events[0] #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.cloud_function_configuration.cloud_function #=> String
    #   resp.cloud_function_configuration.invocation_role #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketNotification AWS API Documentation
    #
    # @overload get_bucket_notification(params = {})
    # @param [Hash] params ({})
    def get_bucket_notification(params = {}, options = {})
      req = build_request(:get_bucket_notification, params)
      req.send_request(options)
    end

    # Returns the notification configuration of a bucket.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket to get the notification configuration for.
    #
    # @return [Types::NotificationConfiguration] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::NotificationConfiguration#topic_configurations #topic_configurations} => Array&lt;Types::TopicConfiguration&gt;
    #   * {Types::NotificationConfiguration#queue_configurations #queue_configurations} => Array&lt;Types::QueueConfiguration&gt;
    #   * {Types::NotificationConfiguration#lambda_function_configurations #lambda_function_configurations} => Array&lt;Types::LambdaFunctionConfiguration&gt;
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_notification_configuration({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.topic_configurations #=> Array
    #   resp.topic_configurations[0].id #=> String
    #   resp.topic_configurations[0].topic_arn #=> String
    #   resp.topic_configurations[0].events #=> Array
    #   resp.topic_configurations[0].events[0] #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.topic_configurations[0].filter.key.filter_rules #=> Array
    #   resp.topic_configurations[0].filter.key.filter_rules[0].name #=> String, one of "prefix", "suffix"
    #   resp.topic_configurations[0].filter.key.filter_rules[0].value #=> String
    #   resp.queue_configurations #=> Array
    #   resp.queue_configurations[0].id #=> String
    #   resp.queue_configurations[0].queue_arn #=> String
    #   resp.queue_configurations[0].events #=> Array
    #   resp.queue_configurations[0].events[0] #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.queue_configurations[0].filter.key.filter_rules #=> Array
    #   resp.queue_configurations[0].filter.key.filter_rules[0].name #=> String, one of "prefix", "suffix"
    #   resp.queue_configurations[0].filter.key.filter_rules[0].value #=> String
    #   resp.lambda_function_configurations #=> Array
    #   resp.lambda_function_configurations[0].id #=> String
    #   resp.lambda_function_configurations[0].lambda_function_arn #=> String
    #   resp.lambda_function_configurations[0].events #=> Array
    #   resp.lambda_function_configurations[0].events[0] #=> String, one of "s3:ReducedRedundancyLostObject", "s3:ObjectCreated:*", "s3:ObjectCreated:Put", "s3:ObjectCreated:Post", "s3:ObjectCreated:Copy", "s3:ObjectCreated:CompleteMultipartUpload", "s3:ObjectRemoved:*", "s3:ObjectRemoved:Delete", "s3:ObjectRemoved:DeleteMarkerCreated"
    #   resp.lambda_function_configurations[0].filter.key.filter_rules #=> Array
    #   resp.lambda_function_configurations[0].filter.key.filter_rules[0].name #=> String, one of "prefix", "suffix"
    #   resp.lambda_function_configurations[0].filter.key.filter_rules[0].value #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketNotificationConfiguration AWS API Documentation
    #
    # @overload get_bucket_notification_configuration(params = {})
    # @param [Hash] params ({})
    def get_bucket_notification_configuration(params = {}, options = {})
      req = build_request(:get_bucket_notification_configuration, params)
      req.send_request(options)
    end

    # Returns the policy of a specified bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketPolicyOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketPolicyOutput#policy #policy} => IO
    #
    #
    # @example Example: To get bucket policy
    #
    #   # The following example returns bucket policy associated with a bucket.
    #
    #   resp = client.get_bucket_policy({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     policy: "{\"Version\":\"2008-10-17\",\"Id\":\"LogPolicy\",\"Statement\":[{\"Sid\":\"Enables the log delivery group to publish logs to your bucket \",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"111122223333\"},\"Action\":[\"s3:GetBucketAcl\",\"s3:GetObjectAcl\",\"s3:PutObject\"],\"Resource\":[\"arn:aws:s3:::policytest1/*\",\"arn:aws:s3:::policytest1\"]}]}", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_policy({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.policy #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketPolicy AWS API Documentation
    #
    # @overload get_bucket_policy(params = {})
    # @param [Hash] params ({})
    def get_bucket_policy(params = {}, options = {}, &block)
      req = build_request(:get_bucket_policy, params)
      req.send_request(options, &block)
    end

    # Returns the replication configuration of a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketReplicationOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketReplicationOutput#replication_configuration #replication_configuration} => Types::ReplicationConfiguration
    #
    #
    # @example Example: To get replication configuration set on a bucket
    #
    #   # The following example returns replication configuration set on a bucket.
    #
    #   resp = client.get_bucket_replication({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     replication_configuration: {
    #       role: "arn:aws:iam::acct-id:role/example-role", 
    #       rules: [
    #         {
    #           destination: {
    #             bucket: "arn:aws:s3:::destination-bucket", 
    #           }, 
    #           id: "MWIwNTkwZmItMTE3MS00ZTc3LWJkZDEtNzRmODQwYzc1OTQy", 
    #           prefix: "Tax", 
    #           status: "Enabled", 
    #         }, 
    #       ], 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_replication({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.replication_configuration.role #=> String
    #   resp.replication_configuration.rules #=> Array
    #   resp.replication_configuration.rules[0].id #=> String
    #   resp.replication_configuration.rules[0].prefix #=> String
    #   resp.replication_configuration.rules[0].status #=> String, one of "Enabled", "Disabled"
    #   resp.replication_configuration.rules[0].source_selection_criteria.sse_kms_encrypted_objects.status #=> String, one of "Enabled", "Disabled"
    #   resp.replication_configuration.rules[0].destination.bucket #=> String
    #   resp.replication_configuration.rules[0].destination.account #=> String
    #   resp.replication_configuration.rules[0].destination.storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA"
    #   resp.replication_configuration.rules[0].destination.access_control_translation.owner #=> String, one of "Destination"
    #   resp.replication_configuration.rules[0].destination.encryption_configuration.replica_kms_key_id #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketReplication AWS API Documentation
    #
    # @overload get_bucket_replication(params = {})
    # @param [Hash] params ({})
    def get_bucket_replication(params = {}, options = {})
      req = build_request(:get_bucket_replication, params)
      req.send_request(options)
    end

    # Returns the request payment configuration of a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketRequestPaymentOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketRequestPaymentOutput#payer #payer} => String
    #
    #
    # @example Example: To get bucket versioning configuration
    #
    #   # The following example retrieves bucket versioning configuration.
    #
    #   resp = client.get_bucket_request_payment({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     payer: "BucketOwner", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_request_payment({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.payer #=> String, one of "Requester", "BucketOwner"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketRequestPayment AWS API Documentation
    #
    # @overload get_bucket_request_payment(params = {})
    # @param [Hash] params ({})
    def get_bucket_request_payment(params = {}, options = {})
      req = build_request(:get_bucket_request_payment, params)
      req.send_request(options)
    end

    # Returns the tag set associated with the bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketTaggingOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketTaggingOutput#tag_set #tag_set} => Array&lt;Types::Tag&gt;
    #
    #
    # @example Example: To get tag set associated with a bucket
    #
    #   # The following example returns tag set associated with a bucket
    #
    #   resp = client.get_bucket_tagging({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     tag_set: [
    #       {
    #         key: "key1", 
    #         value: "value1", 
    #       }, 
    #       {
    #         key: "key2", 
    #         value: "value2", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_tagging({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.tag_set #=> Array
    #   resp.tag_set[0].key #=> String
    #   resp.tag_set[0].value #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketTagging AWS API Documentation
    #
    # @overload get_bucket_tagging(params = {})
    # @param [Hash] params ({})
    def get_bucket_tagging(params = {}, options = {})
      req = build_request(:get_bucket_tagging, params)
      req.send_request(options)
    end

    # Returns the versioning state of a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketVersioningOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketVersioningOutput#status #status} => String
    #   * {Types::GetBucketVersioningOutput#mfa_delete #mfa_delete} => String
    #
    #
    # @example Example: To get bucket versioning configuration
    #
    #   # The following example retrieves bucket versioning configuration.
    #
    #   resp = client.get_bucket_versioning({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     mfa_delete: "Disabled", 
    #     status: "Enabled", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_versioning({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.status #=> String, one of "Enabled", "Suspended"
    #   resp.mfa_delete #=> String, one of "Enabled", "Disabled"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketVersioning AWS API Documentation
    #
    # @overload get_bucket_versioning(params = {})
    # @param [Hash] params ({})
    def get_bucket_versioning(params = {}, options = {})
      req = build_request(:get_bucket_versioning, params)
      req.send_request(options)
    end

    # Returns the website configuration for a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @return [Types::GetBucketWebsiteOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetBucketWebsiteOutput#redirect_all_requests_to #redirect_all_requests_to} => Types::RedirectAllRequestsTo
    #   * {Types::GetBucketWebsiteOutput#index_document #index_document} => Types::IndexDocument
    #   * {Types::GetBucketWebsiteOutput#error_document #error_document} => Types::ErrorDocument
    #   * {Types::GetBucketWebsiteOutput#routing_rules #routing_rules} => Array&lt;Types::RoutingRule&gt;
    #
    #
    # @example Example: To get bucket website configuration
    #
    #   # The following example retrieves website configuration of a bucket.
    #
    #   resp = client.get_bucket_website({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     error_document: {
    #       key: "error.html", 
    #     }, 
    #     index_document: {
    #       suffix: "index.html", 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_bucket_website({
    #     bucket: "BucketName", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.redirect_all_requests_to.host_name #=> String
    #   resp.redirect_all_requests_to.protocol #=> String, one of "http", "https"
    #   resp.index_document.suffix #=> String
    #   resp.error_document.key #=> String
    #   resp.routing_rules #=> Array
    #   resp.routing_rules[0].condition.http_error_code_returned_equals #=> String
    #   resp.routing_rules[0].condition.key_prefix_equals #=> String
    #   resp.routing_rules[0].redirect.host_name #=> String
    #   resp.routing_rules[0].redirect.http_redirect_code #=> String
    #   resp.routing_rules[0].redirect.protocol #=> String, one of "http", "https"
    #   resp.routing_rules[0].redirect.replace_key_prefix_with #=> String
    #   resp.routing_rules[0].redirect.replace_key_with #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketWebsite AWS API Documentation
    #
    # @overload get_bucket_website(params = {})
    # @param [Hash] params ({})
    def get_bucket_website(params = {}, options = {})
      req = build_request(:get_bucket_website, params)
      req.send_request(options)
    end

    # Retrieves objects from Amazon S3.
    #
    # @option params [String, IO] :response_target
    #   Where to write response data, file path, or IO object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :if_match
    #   Return the object only if its entity tag (ETag) is the same as the one
    #   specified, otherwise return a 412 (precondition failed).
    #
    # @option params [Time,DateTime,Date,Integer,String] :if_modified_since
    #   Return the object only if it has been modified since the specified
    #   time, otherwise return a 304 (not modified).
    #
    # @option params [String] :if_none_match
    #   Return the object only if its entity tag (ETag) is different from the
    #   one specified, otherwise return a 304 (not modified).
    #
    # @option params [Time,DateTime,Date,Integer,String] :if_unmodified_since
    #   Return the object only if it has not been modified since the specified
    #   time, otherwise return a 412 (precondition failed).
    #
    # @option params [required, String] :key
    #
    # @option params [String] :range
    #   Downloads the specified range bytes of an object. For more information
    #   about the HTTP Range header, go to
    #   http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
    #
    # @option params [String] :response_cache_control
    #   Sets the Cache-Control header of the response.
    #
    # @option params [String] :response_content_disposition
    #   Sets the Content-Disposition header of the response
    #
    # @option params [String] :response_content_encoding
    #   Sets the Content-Encoding header of the response.
    #
    # @option params [String] :response_content_language
    #   Sets the Content-Language header of the response.
    #
    # @option params [String] :response_content_type
    #   Sets the Content-Type header of the response.
    #
    # @option params [Time,DateTime,Date,Integer,String] :response_expires
    #   Sets the Expires header of the response.
    #
    # @option params [String] :version_id
    #   VersionId used to reference a specific version of the object.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @option params [Integer] :part_number
    #   Part number of the object being read. This is a positive integer
    #   between 1 and 10,000. Effectively performs a 'ranged' GET request
    #   for the part specified. Useful for downloading just a part of an
    #   object.
    #
    # @return [Types::GetObjectOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetObjectOutput#body #body} => IO
    #   * {Types::GetObjectOutput#delete_marker #delete_marker} => Boolean
    #   * {Types::GetObjectOutput#accept_ranges #accept_ranges} => String
    #   * {Types::GetObjectOutput#expiration #expiration} => String
    #   * {Types::GetObjectOutput#restore #restore} => String
    #   * {Types::GetObjectOutput#last_modified #last_modified} => Time
    #   * {Types::GetObjectOutput#content_length #content_length} => Integer
    #   * {Types::GetObjectOutput#etag #etag} => String
    #   * {Types::GetObjectOutput#missing_meta #missing_meta} => Integer
    #   * {Types::GetObjectOutput#version_id #version_id} => String
    #   * {Types::GetObjectOutput#cache_control #cache_control} => String
    #   * {Types::GetObjectOutput#content_disposition #content_disposition} => String
    #   * {Types::GetObjectOutput#content_encoding #content_encoding} => String
    #   * {Types::GetObjectOutput#content_language #content_language} => String
    #   * {Types::GetObjectOutput#content_range #content_range} => String
    #   * {Types::GetObjectOutput#content_type #content_type} => String
    #   * {Types::GetObjectOutput#expires #expires} => Time
    #   * {Types::GetObjectOutput#expires_string #expires_string} => String
    #   * {Types::GetObjectOutput#website_redirect_location #website_redirect_location} => String
    #   * {Types::GetObjectOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::GetObjectOutput#metadata #metadata} => Hash&lt;String,String&gt;
    #   * {Types::GetObjectOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::GetObjectOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::GetObjectOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::GetObjectOutput#storage_class #storage_class} => String
    #   * {Types::GetObjectOutput#request_charged #request_charged} => String
    #   * {Types::GetObjectOutput#replication_status #replication_status} => String
    #   * {Types::GetObjectOutput#parts_count #parts_count} => Integer
    #   * {Types::GetObjectOutput#tag_count #tag_count} => Integer
    #
    #
    # @example Example: To retrieve an object
    #
    #   # The following example retrieves an object for an S3 bucket.
    #
    #   resp = client.get_object({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     accept_ranges: "bytes", 
    #     content_length: 3191, 
    #     content_type: "image/jpeg", 
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     last_modified: Time.parse("Thu, 15 Dec 2016 01:19:41 GMT"), 
    #     metadata: {
    #     }, 
    #     tag_count: 2, 
    #     version_id: "null", 
    #   }
    #
    # @example Example: To retrieve a byte range of an object 
    #
    #   # The following example retrieves an object for an S3 bucket. The request specifies the range header to retrieve a
    #   # specific byte range.
    #
    #   resp = client.get_object({
    #     bucket: "examplebucket", 
    #     key: "SampleFile.txt", 
    #     range: "bytes=0-9", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     accept_ranges: "bytes", 
    #     content_length: 10, 
    #     content_range: "bytes 0-9/43", 
    #     content_type: "text/plain", 
    #     etag: "\"0d94420ffd0bc68cd3d152506b97a9cc\"", 
    #     last_modified: Time.parse("Thu, 09 Oct 2014 22:57:28 GMT"), 
    #     metadata: {
    #     }, 
    #     version_id: "null", 
    #   }
    #
    # @example Download an object to disk
    #   # stream object directly to disk
    #   resp = s3.get_object(
    #     response_target: '/path/to/file',
    #     bucket: 'bucket-name',
    #     key: 'object-key')
    #
    #   # you can still access other response data
    #   resp.metadata #=> { ... }
    #   resp.etag #=> "..."
    #
    # @example Download object into memory
    #   # omit :response_target to download to a StringIO in memory
    #   resp = s3.get_object(bucket: 'bucket-name', key: 'object-key')
    #
    #   # call #read or #string on the response body
    #   resp.body.read
    #   #=> '...'
    #
    # @example Streaming data to a block
    #   # WARNING: yielding data to a block disables retries of networking errors
    #   File.open('/path/to/file', 'wb') do |file|
    #     s3.get_object(bucket: 'bucket-name', key: 'object-key') do |chunk|
    #       file.write(chunk)
    #     end
    #   end
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_object({
    #     bucket: "BucketName", # required
    #     if_match: "IfMatch",
    #     if_modified_since: Time.now,
    #     if_none_match: "IfNoneMatch",
    #     if_unmodified_since: Time.now,
    #     key: "ObjectKey", # required
    #     range: "Range",
    #     response_cache_control: "ResponseCacheControl",
    #     response_content_disposition: "ResponseContentDisposition",
    #     response_content_encoding: "ResponseContentEncoding",
    #     response_content_language: "ResponseContentLanguage",
    #     response_content_type: "ResponseContentType",
    #     response_expires: Time.now,
    #     version_id: "ObjectVersionId",
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #     part_number: 1,
    #   })
    #
    # @example Response structure
    #
    #   resp.body #=> IO
    #   resp.delete_marker #=> Boolean
    #   resp.accept_ranges #=> String
    #   resp.expiration #=> String
    #   resp.restore #=> String
    #   resp.last_modified #=> Time
    #   resp.content_length #=> Integer
    #   resp.etag #=> String
    #   resp.missing_meta #=> Integer
    #   resp.version_id #=> String
    #   resp.cache_control #=> String
    #   resp.content_disposition #=> String
    #   resp.content_encoding #=> String
    #   resp.content_language #=> String
    #   resp.content_range #=> String
    #   resp.content_type #=> String
    #   resp.expires #=> Time
    #   resp.expires_string #=> String
    #   resp.website_redirect_location #=> String
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.metadata #=> Hash
    #   resp.metadata["MetadataKey"] #=> String
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA"
    #   resp.request_charged #=> String, one of "requester"
    #   resp.replication_status #=> String, one of "COMPLETE", "PENDING", "FAILED", "REPLICA"
    #   resp.parts_count #=> Integer
    #   resp.tag_count #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObject AWS API Documentation
    #
    # @overload get_object(params = {})
    # @param [Hash] params ({})
    def get_object(params = {}, options = {}, &block)
      req = build_request(:get_object, params)
      req.send_request(options, &block)
    end

    # Returns the access control list (ACL) of an object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :version_id
    #   VersionId used to reference a specific version of the object.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::GetObjectAclOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetObjectAclOutput#owner #owner} => Types::Owner
    #   * {Types::GetObjectAclOutput#grants #grants} => Array&lt;Types::Grant&gt;
    #   * {Types::GetObjectAclOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To retrieve object ACL
    #
    #   # The following example retrieves access control list (ACL) of an object.
    #
    #   resp = client.get_object_acl({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     grants: [
    #       {
    #         grantee: {
    #           display_name: "owner-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #           type: "CanonicalUser", 
    #         }, 
    #         permission: "WRITE", 
    #       }, 
    #       {
    #         grantee: {
    #           display_name: "owner-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #           type: "CanonicalUser", 
    #         }, 
    #         permission: "WRITE_ACP", 
    #       }, 
    #       {
    #         grantee: {
    #           display_name: "owner-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #           type: "CanonicalUser", 
    #         }, 
    #         permission: "READ", 
    #       }, 
    #       {
    #         grantee: {
    #           display_name: "owner-display-name", 
    #           id: "852b113eexamplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #           type: "CanonicalUser", 
    #         }, 
    #         permission: "READ_ACP", 
    #       }, 
    #     ], 
    #     owner: {
    #       display_name: "owner-display-name", 
    #       id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_object_acl({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     version_id: "ObjectVersionId",
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.owner.display_name #=> String
    #   resp.owner.id #=> String
    #   resp.grants #=> Array
    #   resp.grants[0].grantee.display_name #=> String
    #   resp.grants[0].grantee.email_address #=> String
    #   resp.grants[0].grantee.id #=> String
    #   resp.grants[0].grantee.type #=> String, one of "CanonicalUser", "AmazonCustomerByEmail", "Group"
    #   resp.grants[0].grantee.uri #=> String
    #   resp.grants[0].permission #=> String, one of "FULL_CONTROL", "WRITE", "WRITE_ACP", "READ", "READ_ACP"
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectAcl AWS API Documentation
    #
    # @overload get_object_acl(params = {})
    # @param [Hash] params ({})
    def get_object_acl(params = {}, options = {})
      req = build_request(:get_object_acl, params)
      req.send_request(options)
    end

    # Returns the tag-set of an object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :version_id
    #
    # @return [Types::GetObjectTaggingOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetObjectTaggingOutput#version_id #version_id} => String
    #   * {Types::GetObjectTaggingOutput#tag_set #tag_set} => Array&lt;Types::Tag&gt;
    #
    #
    # @example Example: To retrieve tag set of an object
    #
    #   # The following example retrieves tag set of an object.
    #
    #   resp = client.get_object_tagging({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     tag_set: [
    #       {
    #         key: "Key4", 
    #         value: "Value4", 
    #       }, 
    #       {
    #         key: "Key3", 
    #         value: "Value3", 
    #       }, 
    #     ], 
    #     version_id: "null", 
    #   }
    #
    # @example Example: To retrieve tag set of a specific object version
    #
    #   # The following example retrieves tag set of an object. The request specifies object version.
    #
    #   resp = client.get_object_tagging({
    #     bucket: "examplebucket", 
    #     key: "exampleobject", 
    #     version_id: "ydlaNkwWm0SfKJR.T1b1fIdPRbldTYRI", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     tag_set: [
    #       {
    #         key: "Key1", 
    #         value: "Value1", 
    #       }, 
    #     ], 
    #     version_id: "ydlaNkwWm0SfKJR.T1b1fIdPRbldTYRI", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_object_tagging({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     version_id: "ObjectVersionId",
    #   })
    #
    # @example Response structure
    #
    #   resp.version_id #=> String
    #   resp.tag_set #=> Array
    #   resp.tag_set[0].key #=> String
    #   resp.tag_set[0].value #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectTagging AWS API Documentation
    #
    # @overload get_object_tagging(params = {})
    # @param [Hash] params ({})
    def get_object_tagging(params = {}, options = {})
      req = build_request(:get_object_tagging, params)
      req.send_request(options)
    end

    # Return torrent files from a bucket.
    #
    # @option params [String, IO] :response_target
    #   Where to write response data, file path, or IO object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::GetObjectTorrentOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetObjectTorrentOutput#body #body} => IO
    #   * {Types::GetObjectTorrentOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To retrieve torrent files for an object
    #
    #   # The following example retrieves torrent files of an object.
    #
    #   resp = client.get_object_torrent({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_object_torrent({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.body #=> IO
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectTorrent AWS API Documentation
    #
    # @overload get_object_torrent(params = {})
    # @param [Hash] params ({})
    def get_object_torrent(params = {}, options = {}, &block)
      req = build_request(:get_object_torrent, params)
      req.send_request(options, &block)
    end

    # This operation is useful to determine if a bucket exists and you have
    # permission to access it.
    #
    # @option params [required, String] :bucket
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To determine if bucket exists
    #
    #   # This operation checks to see if a bucket exists.
    #
    #   resp = client.head_bucket({
    #     bucket: "acl1", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.head_bucket({
    #     bucket: "BucketName", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/HeadBucket AWS API Documentation
    #
    # @overload head_bucket(params = {})
    # @param [Hash] params ({})
    def head_bucket(params = {}, options = {})
      req = build_request(:head_bucket, params)
      req.send_request(options)
    end

    # The HEAD operation retrieves metadata from an object without returning
    # the object itself. This operation is useful if you're only interested
    # in an object's metadata. To use HEAD, you must have READ access to
    # the object.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :if_match
    #   Return the object only if its entity tag (ETag) is the same as the one
    #   specified, otherwise return a 412 (precondition failed).
    #
    # @option params [Time,DateTime,Date,Integer,String] :if_modified_since
    #   Return the object only if it has been modified since the specified
    #   time, otherwise return a 304 (not modified).
    #
    # @option params [String] :if_none_match
    #   Return the object only if its entity tag (ETag) is different from the
    #   one specified, otherwise return a 304 (not modified).
    #
    # @option params [Time,DateTime,Date,Integer,String] :if_unmodified_since
    #   Return the object only if it has not been modified since the specified
    #   time, otherwise return a 412 (precondition failed).
    #
    # @option params [required, String] :key
    #
    # @option params [String] :range
    #   Downloads the specified range bytes of an object. For more information
    #   about the HTTP Range header, go to
    #   http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
    #
    # @option params [String] :version_id
    #   VersionId used to reference a specific version of the object.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @option params [Integer] :part_number
    #   Part number of the object being read. This is a positive integer
    #   between 1 and 10,000. Effectively performs a 'ranged' HEAD request
    #   for the part specified. Useful querying about the size of the part and
    #   the number of parts in this object.
    #
    # @return [Types::HeadObjectOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::HeadObjectOutput#delete_marker #delete_marker} => Boolean
    #   * {Types::HeadObjectOutput#accept_ranges #accept_ranges} => String
    #   * {Types::HeadObjectOutput#expiration #expiration} => String
    #   * {Types::HeadObjectOutput#restore #restore} => String
    #   * {Types::HeadObjectOutput#last_modified #last_modified} => Time
    #   * {Types::HeadObjectOutput#content_length #content_length} => Integer
    #   * {Types::HeadObjectOutput#etag #etag} => String
    #   * {Types::HeadObjectOutput#missing_meta #missing_meta} => Integer
    #   * {Types::HeadObjectOutput#version_id #version_id} => String
    #   * {Types::HeadObjectOutput#cache_control #cache_control} => String
    #   * {Types::HeadObjectOutput#content_disposition #content_disposition} => String
    #   * {Types::HeadObjectOutput#content_encoding #content_encoding} => String
    #   * {Types::HeadObjectOutput#content_language #content_language} => String
    #   * {Types::HeadObjectOutput#content_type #content_type} => String
    #   * {Types::HeadObjectOutput#expires #expires} => Time
    #   * {Types::HeadObjectOutput#expires_string #expires_string} => String
    #   * {Types::HeadObjectOutput#website_redirect_location #website_redirect_location} => String
    #   * {Types::HeadObjectOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::HeadObjectOutput#metadata #metadata} => Hash&lt;String,String&gt;
    #   * {Types::HeadObjectOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::HeadObjectOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::HeadObjectOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::HeadObjectOutput#storage_class #storage_class} => String
    #   * {Types::HeadObjectOutput#request_charged #request_charged} => String
    #   * {Types::HeadObjectOutput#replication_status #replication_status} => String
    #   * {Types::HeadObjectOutput#parts_count #parts_count} => Integer
    #
    #
    # @example Example: To retrieve metadata of an object without returning the object itself
    #
    #   # The following example retrieves an object metadata.
    #
    #   resp = client.head_object({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     accept_ranges: "bytes", 
    #     content_length: 3191, 
    #     content_type: "image/jpeg", 
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     last_modified: Time.parse("Thu, 15 Dec 2016 01:19:41 GMT"), 
    #     metadata: {
    #     }, 
    #     version_id: "null", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.head_object({
    #     bucket: "BucketName", # required
    #     if_match: "IfMatch",
    #     if_modified_since: Time.now,
    #     if_none_match: "IfNoneMatch",
    #     if_unmodified_since: Time.now,
    #     key: "ObjectKey", # required
    #     range: "Range",
    #     version_id: "ObjectVersionId",
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #     part_number: 1,
    #   })
    #
    # @example Response structure
    #
    #   resp.delete_marker #=> Boolean
    #   resp.accept_ranges #=> String
    #   resp.expiration #=> String
    #   resp.restore #=> String
    #   resp.last_modified #=> Time
    #   resp.content_length #=> Integer
    #   resp.etag #=> String
    #   resp.missing_meta #=> Integer
    #   resp.version_id #=> String
    #   resp.cache_control #=> String
    #   resp.content_disposition #=> String
    #   resp.content_encoding #=> String
    #   resp.content_language #=> String
    #   resp.content_type #=> String
    #   resp.expires #=> Time
    #   resp.expires_string #=> String
    #   resp.website_redirect_location #=> String
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.metadata #=> Hash
    #   resp.metadata["MetadataKey"] #=> String
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA"
    #   resp.request_charged #=> String, one of "requester"
    #   resp.replication_status #=> String, one of "COMPLETE", "PENDING", "FAILED", "REPLICA"
    #   resp.parts_count #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/HeadObject AWS API Documentation
    #
    # @overload head_object(params = {})
    # @param [Hash] params ({})
    def head_object(params = {}, options = {})
      req = build_request(:head_object, params)
      req.send_request(options)
    end

    # Lists the analytics configurations for the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket from which analytics configurations are
    #   retrieved.
    #
    # @option params [String] :continuation_token
    #   The ContinuationToken that represents a placeholder from where this
    #   request should begin.
    #
    # @return [Types::ListBucketAnalyticsConfigurationsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListBucketAnalyticsConfigurationsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListBucketAnalyticsConfigurationsOutput#continuation_token #continuation_token} => String
    #   * {Types::ListBucketAnalyticsConfigurationsOutput#next_continuation_token #next_continuation_token} => String
    #   * {Types::ListBucketAnalyticsConfigurationsOutput#analytics_configuration_list #analytics_configuration_list} => Array&lt;Types::AnalyticsConfiguration&gt;
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_bucket_analytics_configurations({
    #     bucket: "BucketName", # required
    #     continuation_token: "Token",
    #   })
    #
    # @example Response structure
    #
    #   resp.is_truncated #=> Boolean
    #   resp.continuation_token #=> String
    #   resp.next_continuation_token #=> String
    #   resp.analytics_configuration_list #=> Array
    #   resp.analytics_configuration_list[0].id #=> String
    #   resp.analytics_configuration_list[0].filter.prefix #=> String
    #   resp.analytics_configuration_list[0].filter.tag.key #=> String
    #   resp.analytics_configuration_list[0].filter.tag.value #=> String
    #   resp.analytics_configuration_list[0].filter.and.prefix #=> String
    #   resp.analytics_configuration_list[0].filter.and.tags #=> Array
    #   resp.analytics_configuration_list[0].filter.and.tags[0].key #=> String
    #   resp.analytics_configuration_list[0].filter.and.tags[0].value #=> String
    #   resp.analytics_configuration_list[0].storage_class_analysis.data_export.output_schema_version #=> String, one of "V_1"
    #   resp.analytics_configuration_list[0].storage_class_analysis.data_export.destination.s3_bucket_destination.format #=> String, one of "CSV"
    #   resp.analytics_configuration_list[0].storage_class_analysis.data_export.destination.s3_bucket_destination.bucket_account_id #=> String
    #   resp.analytics_configuration_list[0].storage_class_analysis.data_export.destination.s3_bucket_destination.bucket #=> String
    #   resp.analytics_configuration_list[0].storage_class_analysis.data_export.destination.s3_bucket_destination.prefix #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketAnalyticsConfigurations AWS API Documentation
    #
    # @overload list_bucket_analytics_configurations(params = {})
    # @param [Hash] params ({})
    def list_bucket_analytics_configurations(params = {}, options = {})
      req = build_request(:list_bucket_analytics_configurations, params)
      req.send_request(options)
    end

    # Returns a list of inventory configurations for the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the inventory configurations to
    #   retrieve.
    #
    # @option params [String] :continuation_token
    #   The marker used to continue an inventory configuration listing that
    #   has been truncated. Use the NextContinuationToken from a previously
    #   truncated list response to continue the listing. The continuation
    #   token is an opaque value that Amazon S3 understands.
    #
    # @return [Types::ListBucketInventoryConfigurationsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListBucketInventoryConfigurationsOutput#continuation_token #continuation_token} => String
    #   * {Types::ListBucketInventoryConfigurationsOutput#inventory_configuration_list #inventory_configuration_list} => Array&lt;Types::InventoryConfiguration&gt;
    #   * {Types::ListBucketInventoryConfigurationsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListBucketInventoryConfigurationsOutput#next_continuation_token #next_continuation_token} => String
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_bucket_inventory_configurations({
    #     bucket: "BucketName", # required
    #     continuation_token: "Token",
    #   })
    #
    # @example Response structure
    #
    #   resp.continuation_token #=> String
    #   resp.inventory_configuration_list #=> Array
    #   resp.inventory_configuration_list[0].destination.s3_bucket_destination.account_id #=> String
    #   resp.inventory_configuration_list[0].destination.s3_bucket_destination.bucket #=> String
    #   resp.inventory_configuration_list[0].destination.s3_bucket_destination.format #=> String, one of "CSV", "ORC"
    #   resp.inventory_configuration_list[0].destination.s3_bucket_destination.prefix #=> String
    #   resp.inventory_configuration_list[0].destination.s3_bucket_destination.encryption.ssekms.key_id #=> String
    #   resp.inventory_configuration_list[0].is_enabled #=> Boolean
    #   resp.inventory_configuration_list[0].filter.prefix #=> String
    #   resp.inventory_configuration_list[0].id #=> String
    #   resp.inventory_configuration_list[0].included_object_versions #=> String, one of "All", "Current"
    #   resp.inventory_configuration_list[0].optional_fields #=> Array
    #   resp.inventory_configuration_list[0].optional_fields[0] #=> String, one of "Size", "LastModifiedDate", "StorageClass", "ETag", "IsMultipartUploaded", "ReplicationStatus", "EncryptionStatus"
    #   resp.inventory_configuration_list[0].schedule.frequency #=> String, one of "Daily", "Weekly"
    #   resp.is_truncated #=> Boolean
    #   resp.next_continuation_token #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketInventoryConfigurations AWS API Documentation
    #
    # @overload list_bucket_inventory_configurations(params = {})
    # @param [Hash] params ({})
    def list_bucket_inventory_configurations(params = {}, options = {})
      req = build_request(:list_bucket_inventory_configurations, params)
      req.send_request(options)
    end

    # Lists the metrics configurations for the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket containing the metrics configurations to
    #   retrieve.
    #
    # @option params [String] :continuation_token
    #   The marker that is used to continue a metrics configuration listing
    #   that has been truncated. Use the NextContinuationToken from a
    #   previously truncated list response to continue the listing. The
    #   continuation token is an opaque value that Amazon S3 understands.
    #
    # @return [Types::ListBucketMetricsConfigurationsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListBucketMetricsConfigurationsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListBucketMetricsConfigurationsOutput#continuation_token #continuation_token} => String
    #   * {Types::ListBucketMetricsConfigurationsOutput#next_continuation_token #next_continuation_token} => String
    #   * {Types::ListBucketMetricsConfigurationsOutput#metrics_configuration_list #metrics_configuration_list} => Array&lt;Types::MetricsConfiguration&gt;
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_bucket_metrics_configurations({
    #     bucket: "BucketName", # required
    #     continuation_token: "Token",
    #   })
    #
    # @example Response structure
    #
    #   resp.is_truncated #=> Boolean
    #   resp.continuation_token #=> String
    #   resp.next_continuation_token #=> String
    #   resp.metrics_configuration_list #=> Array
    #   resp.metrics_configuration_list[0].id #=> String
    #   resp.metrics_configuration_list[0].filter.prefix #=> String
    #   resp.metrics_configuration_list[0].filter.tag.key #=> String
    #   resp.metrics_configuration_list[0].filter.tag.value #=> String
    #   resp.metrics_configuration_list[0].filter.and.prefix #=> String
    #   resp.metrics_configuration_list[0].filter.and.tags #=> Array
    #   resp.metrics_configuration_list[0].filter.and.tags[0].key #=> String
    #   resp.metrics_configuration_list[0].filter.and.tags[0].value #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketMetricsConfigurations AWS API Documentation
    #
    # @overload list_bucket_metrics_configurations(params = {})
    # @param [Hash] params ({})
    def list_bucket_metrics_configurations(params = {}, options = {})
      req = build_request(:list_bucket_metrics_configurations, params)
      req.send_request(options)
    end

    # Returns a list of all buckets owned by the authenticated sender of the
    # request.
    #
    # @return [Types::ListBucketsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListBucketsOutput#buckets #buckets} => Array&lt;Types::Bucket&gt;
    #   * {Types::ListBucketsOutput#owner #owner} => Types::Owner
    #
    #
    # @example Example: To list object versions
    #
    #   # The following example return versions of an object with specific key name prefix. The request limits the number of items
    #   # returned to two. If there are are more than two object version, S3 returns NextToken in the response. You can specify
    #   # this token value in your next request to fetch next set of object versions.
    #
    #   resp = client.list_buckets({
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     buckets: [
    #       {
    #         creation_date: Time.parse("2012-02-15T21: 03: 02.000Z"), 
    #         name: "examplebucket", 
    #       }, 
    #       {
    #         creation_date: Time.parse("2011-07-24T19: 33: 50.000Z"), 
    #         name: "examplebucket2", 
    #       }, 
    #       {
    #         creation_date: Time.parse("2010-12-17T00: 56: 49.000Z"), 
    #         name: "examplebucket3", 
    #       }, 
    #     ], 
    #     owner: {
    #       display_name: "own-display-name", 
    #       id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31", 
    #     }, 
    #   }
    #
    # @example Response structure
    #
    #   resp.buckets #=> Array
    #   resp.buckets[0].name #=> String
    #   resp.buckets[0].creation_date #=> Time
    #   resp.owner.display_name #=> String
    #   resp.owner.id #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBuckets AWS API Documentation
    #
    # @overload list_buckets(params = {})
    # @param [Hash] params ({})
    def list_buckets(params = {}, options = {})
      req = build_request(:list_buckets, params)
      req.send_request(options)
    end

    # This operation lists in-progress multipart uploads.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :delimiter
    #   Character you use to group keys.
    #
    # @option params [String] :encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    #
    # @option params [String] :key_marker
    #   Together with upload-id-marker, this parameter specifies the multipart
    #   upload after which listing should begin.
    #
    # @option params [Integer] :max_uploads
    #   Sets the maximum number of multipart uploads, from 1 to 1,000, to
    #   return in the response body. 1,000 is the maximum number of uploads
    #   that can be returned in a response.
    #
    # @option params [String] :prefix
    #   Lists in-progress uploads only for those keys that begin with the
    #   specified prefix.
    #
    # @option params [String] :upload_id_marker
    #   Together with key-marker, specifies the multipart upload after which
    #   listing should begin. If key-marker is not specified, the
    #   upload-id-marker parameter is ignored.
    #
    # @return [Types::ListMultipartUploadsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListMultipartUploadsOutput#bucket #bucket} => String
    #   * {Types::ListMultipartUploadsOutput#key_marker #key_marker} => String
    #   * {Types::ListMultipartUploadsOutput#upload_id_marker #upload_id_marker} => String
    #   * {Types::ListMultipartUploadsOutput#next_key_marker #next_key_marker} => String
    #   * {Types::ListMultipartUploadsOutput#prefix #prefix} => String
    #   * {Types::ListMultipartUploadsOutput#delimiter #delimiter} => String
    #   * {Types::ListMultipartUploadsOutput#next_upload_id_marker #next_upload_id_marker} => String
    #   * {Types::ListMultipartUploadsOutput#max_uploads #max_uploads} => Integer
    #   * {Types::ListMultipartUploadsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListMultipartUploadsOutput#uploads #uploads} => Array&lt;Types::MultipartUpload&gt;
    #   * {Types::ListMultipartUploadsOutput#common_prefixes #common_prefixes} => Array&lt;Types::CommonPrefix&gt;
    #   * {Types::ListMultipartUploadsOutput#encoding_type #encoding_type} => String
    #
    #
    # @example Example: To list in-progress multipart uploads on a bucket
    #
    #   # The following example lists in-progress multipart uploads on a specific bucket.
    #
    #   resp = client.list_multipart_uploads({
    #     bucket: "examplebucket", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     uploads: [
    #       {
    #         initiated: Time.parse("2014-05-01T05:40:58.000Z"), 
    #         initiator: {
    #           display_name: "display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         key: "JavaFile", 
    #         owner: {
    #           display_name: "display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         storage_class: "STANDARD", 
    #         upload_id: "examplelUa.CInXklLQtSMJITdUnoZ1Y5GACB5UckOtspm5zbDMCkPF_qkfZzMiFZ6dksmcnqxJyIBvQMG9X9Q--", 
    #       }, 
    #       {
    #         initiated: Time.parse("2014-05-01T05:41:27.000Z"), 
    #         initiator: {
    #           display_name: "display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         key: "JavaFile", 
    #         owner: {
    #           display_name: "display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         storage_class: "STANDARD", 
    #         upload_id: "examplelo91lv1iwvWpvCiJWugw2xXLPAD7Z8cJyX9.WiIRgNrdG6Ldsn.9FtS63TCl1Uf5faTB.1U5Ckcbmdw--", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Example: List next set of multipart uploads when previous result is truncated
    #
    #   # The following example specifies the upload-id-marker and key-marker from previous truncated response to retrieve next
    #   # setup of multipart uploads.
    #
    #   resp = client.list_multipart_uploads({
    #     bucket: "examplebucket", 
    #     key_marker: "nextkeyfrompreviousresponse", 
    #     max_uploads: 2, 
    #     upload_id_marker: "valuefrompreviousresponse", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     bucket: "acl1", 
    #     is_truncated: true, 
    #     key_marker: "", 
    #     max_uploads: 2, 
    #     next_key_marker: "someobjectkey", 
    #     next_upload_id_marker: "examplelo91lv1iwvWpvCiJWugw2xXLPAD7Z8cJyX9.WiIRgNrdG6Ldsn.9FtS63TCl1Uf5faTB.1U5Ckcbmdw--", 
    #     upload_id_marker: "", 
    #     uploads: [
    #       {
    #         initiated: Time.parse("2014-05-01T05:40:58.000Z"), 
    #         initiator: {
    #           display_name: "ownder-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         key: "JavaFile", 
    #         owner: {
    #           display_name: "mohanataws", 
    #           id: "852b113e7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         storage_class: "STANDARD", 
    #         upload_id: "gZ30jIqlUa.CInXklLQtSMJITdUnoZ1Y5GACB5UckOtspm5zbDMCkPF_qkfZzMiFZ6dksmcnqxJyIBvQMG9X9Q--", 
    #       }, 
    #       {
    #         initiated: Time.parse("2014-05-01T05:41:27.000Z"), 
    #         initiator: {
    #           display_name: "ownder-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         key: "JavaFile", 
    #         owner: {
    #           display_name: "ownder-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         storage_class: "STANDARD", 
    #         upload_id: "b7tZSqIlo91lv1iwvWpvCiJWugw2xXLPAD7Z8cJyX9.WiIRgNrdG6Ldsn.9FtS63TCl1Uf5faTB.1U5Ckcbmdw--", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_multipart_uploads({
    #     bucket: "BucketName", # required
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     key_marker: "KeyMarker",
    #     max_uploads: 1,
    #     prefix: "Prefix",
    #     upload_id_marker: "UploadIdMarker",
    #   })
    #
    # @example Response structure
    #
    #   resp.bucket #=> String
    #   resp.key_marker #=> String
    #   resp.upload_id_marker #=> String
    #   resp.next_key_marker #=> String
    #   resp.prefix #=> String
    #   resp.delimiter #=> String
    #   resp.next_upload_id_marker #=> String
    #   resp.max_uploads #=> Integer
    #   resp.is_truncated #=> Boolean
    #   resp.uploads #=> Array
    #   resp.uploads[0].upload_id #=> String
    #   resp.uploads[0].key #=> String
    #   resp.uploads[0].initiated #=> Time
    #   resp.uploads[0].storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA"
    #   resp.uploads[0].owner.display_name #=> String
    #   resp.uploads[0].owner.id #=> String
    #   resp.uploads[0].initiator.id #=> String
    #   resp.uploads[0].initiator.display_name #=> String
    #   resp.common_prefixes #=> Array
    #   resp.common_prefixes[0].prefix #=> String
    #   resp.encoding_type #=> String, one of "url"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListMultipartUploads AWS API Documentation
    #
    # @overload list_multipart_uploads(params = {})
    # @param [Hash] params ({})
    def list_multipart_uploads(params = {}, options = {})
      req = build_request(:list_multipart_uploads, params)
      req.send_request(options)
    end

    # Returns metadata about all of the versions of objects in a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :delimiter
    #   A delimiter is a character you use to group keys.
    #
    # @option params [String] :encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    #
    # @option params [String] :key_marker
    #   Specifies the key to start with when listing objects in a bucket.
    #
    # @option params [Integer] :max_keys
    #   Sets the maximum number of keys returned in the response. The response
    #   might contain fewer keys but will never contain more.
    #
    # @option params [String] :prefix
    #   Limits the response to keys that begin with the specified prefix.
    #
    # @option params [String] :version_id_marker
    #   Specifies the object version you want to start listing from.
    #
    # @return [Types::ListObjectVersionsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListObjectVersionsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListObjectVersionsOutput#key_marker #key_marker} => String
    #   * {Types::ListObjectVersionsOutput#version_id_marker #version_id_marker} => String
    #   * {Types::ListObjectVersionsOutput#next_key_marker #next_key_marker} => String
    #   * {Types::ListObjectVersionsOutput#next_version_id_marker #next_version_id_marker} => String
    #   * {Types::ListObjectVersionsOutput#versions #versions} => Array&lt;Types::ObjectVersion&gt;
    #   * {Types::ListObjectVersionsOutput#delete_markers #delete_markers} => Array&lt;Types::DeleteMarkerEntry&gt;
    #   * {Types::ListObjectVersionsOutput#name #name} => String
    #   * {Types::ListObjectVersionsOutput#prefix #prefix} => String
    #   * {Types::ListObjectVersionsOutput#delimiter #delimiter} => String
    #   * {Types::ListObjectVersionsOutput#max_keys #max_keys} => Integer
    #   * {Types::ListObjectVersionsOutput#common_prefixes #common_prefixes} => Array&lt;Types::CommonPrefix&gt;
    #   * {Types::ListObjectVersionsOutput#encoding_type #encoding_type} => String
    #
    #
    # @example Example: To list object versions
    #
    #   # The following example return versions of an object with specific key name prefix. The request limits the number of items
    #   # returned to two. If there are are more than two object version, S3 returns NextToken in the response. You can specify
    #   # this token value in your next request to fetch next set of object versions.
    #
    #   resp = client.list_object_versions({
    #     bucket: "examplebucket", 
    #     prefix: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     versions: [
    #       {
    #         etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #         is_latest: true, 
    #         key: "HappyFace.jpg", 
    #         last_modified: Time.parse("2016-12-15T01:19:41.000Z"), 
    #         owner: {
    #           display_name: "owner-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         size: 3191, 
    #         storage_class: "STANDARD", 
    #         version_id: "null", 
    #       }, 
    #       {
    #         etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #         is_latest: false, 
    #         key: "HappyFace.jpg", 
    #         last_modified: Time.parse("2016-12-13T00:58:26.000Z"), 
    #         owner: {
    #           display_name: "owner-display-name", 
    #           id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         size: 3191, 
    #         storage_class: "STANDARD", 
    #         version_id: "PHtexPGjH2y.zBgT8LmB7wwLI2mpbz.k", 
    #       }, 
    #     ], 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_object_versions({
    #     bucket: "BucketName", # required
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     key_marker: "KeyMarker",
    #     max_keys: 1,
    #     prefix: "Prefix",
    #     version_id_marker: "VersionIdMarker",
    #   })
    #
    # @example Response structure
    #
    #   resp.is_truncated #=> Boolean
    #   resp.key_marker #=> String
    #   resp.version_id_marker #=> String
    #   resp.next_key_marker #=> String
    #   resp.next_version_id_marker #=> String
    #   resp.versions #=> Array
    #   resp.versions[0].etag #=> String
    #   resp.versions[0].size #=> Integer
    #   resp.versions[0].storage_class #=> String, one of "STANDARD"
    #   resp.versions[0].key #=> String
    #   resp.versions[0].version_id #=> String
    #   resp.versions[0].is_latest #=> Boolean
    #   resp.versions[0].last_modified #=> Time
    #   resp.versions[0].owner.display_name #=> String
    #   resp.versions[0].owner.id #=> String
    #   resp.delete_markers #=> Array
    #   resp.delete_markers[0].owner.display_name #=> String
    #   resp.delete_markers[0].owner.id #=> String
    #   resp.delete_markers[0].key #=> String
    #   resp.delete_markers[0].version_id #=> String
    #   resp.delete_markers[0].is_latest #=> Boolean
    #   resp.delete_markers[0].last_modified #=> Time
    #   resp.name #=> String
    #   resp.prefix #=> String
    #   resp.delimiter #=> String
    #   resp.max_keys #=> Integer
    #   resp.common_prefixes #=> Array
    #   resp.common_prefixes[0].prefix #=> String
    #   resp.encoding_type #=> String, one of "url"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectVersions AWS API Documentation
    #
    # @overload list_object_versions(params = {})
    # @param [Hash] params ({})
    def list_object_versions(params = {}, options = {})
      req = build_request(:list_object_versions, params)
      req.send_request(options)
    end

    # Returns some or all (up to 1000) of the objects in a bucket. You can
    # use the request parameters as selection criteria to return a subset of
    # the objects in a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :delimiter
    #   A delimiter is a character you use to group keys.
    #
    # @option params [String] :encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    #
    # @option params [String] :marker
    #   Specifies the key to start with when listing objects in a bucket.
    #
    # @option params [Integer] :max_keys
    #   Sets the maximum number of keys returned in the response. The response
    #   might contain fewer keys but will never contain more.
    #
    # @option params [String] :prefix
    #   Limits the response to keys that begin with the specified prefix.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the list objects request. Bucket owners need not specify this
    #   parameter in their requests.
    #
    # @return [Types::ListObjectsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListObjectsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListObjectsOutput#marker #marker} => String
    #   * {Types::ListObjectsOutput#next_marker #next_marker} => String
    #   * {Types::ListObjectsOutput#contents #contents} => Array&lt;Types::Object&gt;
    #   * {Types::ListObjectsOutput#name #name} => String
    #   * {Types::ListObjectsOutput#prefix #prefix} => String
    #   * {Types::ListObjectsOutput#delimiter #delimiter} => String
    #   * {Types::ListObjectsOutput#max_keys #max_keys} => Integer
    #   * {Types::ListObjectsOutput#common_prefixes #common_prefixes} => Array&lt;Types::CommonPrefix&gt;
    #   * {Types::ListObjectsOutput#encoding_type #encoding_type} => String
    #
    #
    # @example Example: To list objects in a bucket
    #
    #   # The following example list two objects in a bucket.
    #
    #   resp = client.list_objects({
    #     bucket: "examplebucket", 
    #     max_keys: 2, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     contents: [
    #       {
    #         etag: "\"70ee1738b6b21e2c8a43f3a5ab0eee71\"", 
    #         key: "example1.jpg", 
    #         last_modified: Time.parse("2014-11-21T19:40:05.000Z"), 
    #         owner: {
    #           display_name: "myname", 
    #           id: "12345example25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         size: 11, 
    #         storage_class: "STANDARD", 
    #       }, 
    #       {
    #         etag: "\"9c8af9a76df052144598c115ef33e511\"", 
    #         key: "example2.jpg", 
    #         last_modified: Time.parse("2013-11-15T01:10:49.000Z"), 
    #         owner: {
    #           display_name: "myname", 
    #           id: "12345example25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #         }, 
    #         size: 713193, 
    #         storage_class: "STANDARD", 
    #       }, 
    #     ], 
    #     next_marker: "eyJNYXJrZXIiOiBudWxsLCAiYm90b190cnVuY2F0ZV9hbW91bnQiOiAyfQ==", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_objects({
    #     bucket: "BucketName", # required
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     marker: "Marker",
    #     max_keys: 1,
    #     prefix: "Prefix",
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.is_truncated #=> Boolean
    #   resp.marker #=> String
    #   resp.next_marker #=> String
    #   resp.contents #=> Array
    #   resp.contents[0].key #=> String
    #   resp.contents[0].last_modified #=> Time
    #   resp.contents[0].etag #=> String
    #   resp.contents[0].size #=> Integer
    #   resp.contents[0].storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "GLACIER", "STANDARD_IA", "ONEZONE_IA"
    #   resp.contents[0].owner.display_name #=> String
    #   resp.contents[0].owner.id #=> String
    #   resp.name #=> String
    #   resp.prefix #=> String
    #   resp.delimiter #=> String
    #   resp.max_keys #=> Integer
    #   resp.common_prefixes #=> Array
    #   resp.common_prefixes[0].prefix #=> String
    #   resp.encoding_type #=> String, one of "url"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjects AWS API Documentation
    #
    # @overload list_objects(params = {})
    # @param [Hash] params ({})
    def list_objects(params = {}, options = {})
      req = build_request(:list_objects, params)
      req.send_request(options)
    end

    # Returns some or all (up to 1000) of the objects in a bucket. You can
    # use the request parameters as selection criteria to return a subset of
    # the objects in a bucket. Note: ListObjectsV2 is the revised List
    # Objects API and we recommend you use this revised API for new
    # application development.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket to list.
    #
    # @option params [String] :delimiter
    #   A delimiter is a character you use to group keys.
    #
    # @option params [String] :encoding_type
    #   Encoding type used by Amazon S3 to encode object keys in the response.
    #
    # @option params [Integer] :max_keys
    #   Sets the maximum number of keys returned in the response. The response
    #   might contain fewer keys but will never contain more.
    #
    # @option params [String] :prefix
    #   Limits the response to keys that begin with the specified prefix.
    #
    # @option params [String] :continuation_token
    #   ContinuationToken indicates Amazon S3 that the list is being continued
    #   on this bucket with a token. ContinuationToken is obfuscated and is
    #   not a real key
    #
    # @option params [Boolean] :fetch_owner
    #   The owner field is not present in listV2 by default, if you want to
    #   return owner field with each key in the result then set the fetch
    #   owner field to true
    #
    # @option params [String] :start_after
    #   StartAfter is where you want Amazon S3 to start listing from. Amazon
    #   S3 starts listing after this specified key. StartAfter can be any key
    #   in the bucket
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the list objects request in V2 style. Bucket owners need not specify
    #   this parameter in their requests.
    #
    # @return [Types::ListObjectsV2Output] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListObjectsV2Output#is_truncated #is_truncated} => Boolean
    #   * {Types::ListObjectsV2Output#contents #contents} => Array&lt;Types::Object&gt;
    #   * {Types::ListObjectsV2Output#name #name} => String
    #   * {Types::ListObjectsV2Output#prefix #prefix} => String
    #   * {Types::ListObjectsV2Output#delimiter #delimiter} => String
    #   * {Types::ListObjectsV2Output#max_keys #max_keys} => Integer
    #   * {Types::ListObjectsV2Output#common_prefixes #common_prefixes} => Array&lt;Types::CommonPrefix&gt;
    #   * {Types::ListObjectsV2Output#encoding_type #encoding_type} => String
    #   * {Types::ListObjectsV2Output#key_count #key_count} => Integer
    #   * {Types::ListObjectsV2Output#continuation_token #continuation_token} => String
    #   * {Types::ListObjectsV2Output#next_continuation_token #next_continuation_token} => String
    #   * {Types::ListObjectsV2Output#start_after #start_after} => String
    #
    #
    # @example Example: To get object list
    #
    #   # The following example retrieves object list. The request specifies max keys to limit response to include only 2 object
    #   # keys. 
    #
    #   resp = client.list_objects_v2({
    #     bucket: "examplebucket", 
    #     max_keys: 2, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     contents: [
    #       {
    #         etag: "\"70ee1738b6b21e2c8a43f3a5ab0eee71\"", 
    #         key: "happyface.jpg", 
    #         last_modified: Time.parse("2014-11-21T19:40:05.000Z"), 
    #         size: 11, 
    #         storage_class: "STANDARD", 
    #       }, 
    #       {
    #         etag: "\"becf17f89c30367a9a44495d62ed521a-1\"", 
    #         key: "test.jpg", 
    #         last_modified: Time.parse("2014-05-02T04:51:50.000Z"), 
    #         size: 4192256, 
    #         storage_class: "STANDARD", 
    #       }, 
    #     ], 
    #     is_truncated: true, 
    #     key_count: 2, 
    #     max_keys: 2, 
    #     name: "examplebucket", 
    #     next_continuation_token: "1w41l63U0xa8q7smH50vCxyTQqdxo69O3EmK28Bi5PcROI4wI/EyIJg==", 
    #     prefix: "", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_objects_v2({
    #     bucket: "BucketName", # required
    #     delimiter: "Delimiter",
    #     encoding_type: "url", # accepts url
    #     max_keys: 1,
    #     prefix: "Prefix",
    #     continuation_token: "Token",
    #     fetch_owner: false,
    #     start_after: "StartAfter",
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.is_truncated #=> Boolean
    #   resp.contents #=> Array
    #   resp.contents[0].key #=> String
    #   resp.contents[0].last_modified #=> Time
    #   resp.contents[0].etag #=> String
    #   resp.contents[0].size #=> Integer
    #   resp.contents[0].storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "GLACIER", "STANDARD_IA", "ONEZONE_IA"
    #   resp.contents[0].owner.display_name #=> String
    #   resp.contents[0].owner.id #=> String
    #   resp.name #=> String
    #   resp.prefix #=> String
    #   resp.delimiter #=> String
    #   resp.max_keys #=> Integer
    #   resp.common_prefixes #=> Array
    #   resp.common_prefixes[0].prefix #=> String
    #   resp.encoding_type #=> String, one of "url"
    #   resp.key_count #=> Integer
    #   resp.continuation_token #=> String
    #   resp.next_continuation_token #=> String
    #   resp.start_after #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectsV2 AWS API Documentation
    #
    # @overload list_objects_v2(params = {})
    # @param [Hash] params ({})
    def list_objects_v2(params = {}, options = {})
      req = build_request(:list_objects_v2, params)
      req.send_request(options)
    end

    # Lists the parts that have been uploaded for a specific multipart
    # upload.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [Integer] :max_parts
    #   Sets the maximum number of parts to return.
    #
    # @option params [Integer] :part_number_marker
    #   Specifies the part after which listing should begin. Only parts with
    #   higher part numbers will be listed.
    #
    # @option params [required, String] :upload_id
    #   Upload ID identifying the multipart upload whose parts are being
    #   listed.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::ListPartsOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::ListPartsOutput#abort_date #abort_date} => Time
    #   * {Types::ListPartsOutput#abort_rule_id #abort_rule_id} => String
    #   * {Types::ListPartsOutput#bucket #bucket} => String
    #   * {Types::ListPartsOutput#key #key} => String
    #   * {Types::ListPartsOutput#upload_id #upload_id} => String
    #   * {Types::ListPartsOutput#part_number_marker #part_number_marker} => Integer
    #   * {Types::ListPartsOutput#next_part_number_marker #next_part_number_marker} => Integer
    #   * {Types::ListPartsOutput#max_parts #max_parts} => Integer
    #   * {Types::ListPartsOutput#is_truncated #is_truncated} => Boolean
    #   * {Types::ListPartsOutput#parts #parts} => Array&lt;Types::Part&gt;
    #   * {Types::ListPartsOutput#initiator #initiator} => Types::Initiator
    #   * {Types::ListPartsOutput#owner #owner} => Types::Owner
    #   * {Types::ListPartsOutput#storage_class #storage_class} => String
    #   * {Types::ListPartsOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To list parts of a multipart upload.
    #
    #   # The following example lists parts uploaded for a specific multipart upload.
    #
    #   resp = client.list_parts({
    #     bucket: "examplebucket", 
    #     key: "bigobject", 
    #     upload_id: "example7YPBOJuoFiQ9cz4P3Pe6FIZwO4f7wN93uHsNBEw97pl5eNwzExg0LAT2dUN91cOmrEQHDsP3WA60CEg--", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     initiator: {
    #       display_name: "owner-display-name", 
    #       id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #     }, 
    #     owner: {
    #       display_name: "owner-display-name", 
    #       id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31bebcc", 
    #     }, 
    #     parts: [
    #       {
    #         etag: "\"d8c2eafd90c266e19ab9dcacc479f8af\"", 
    #         last_modified: Time.parse("2016-12-16T00:11:42.000Z"), 
    #         part_number: 1, 
    #         size: 26246026, 
    #       }, 
    #       {
    #         etag: "\"d8c2eafd90c266e19ab9dcacc479f8af\"", 
    #         last_modified: Time.parse("2016-12-16T00:15:01.000Z"), 
    #         part_number: 2, 
    #         size: 26246026, 
    #       }, 
    #     ], 
    #     storage_class: "STANDARD", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_parts({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     max_parts: 1,
    #     part_number_marker: 1,
    #     upload_id: "MultipartUploadId", # required
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.abort_date #=> Time
    #   resp.abort_rule_id #=> String
    #   resp.bucket #=> String
    #   resp.key #=> String
    #   resp.upload_id #=> String
    #   resp.part_number_marker #=> Integer
    #   resp.next_part_number_marker #=> Integer
    #   resp.max_parts #=> Integer
    #   resp.is_truncated #=> Boolean
    #   resp.parts #=> Array
    #   resp.parts[0].part_number #=> Integer
    #   resp.parts[0].last_modified #=> Time
    #   resp.parts[0].etag #=> String
    #   resp.parts[0].size #=> Integer
    #   resp.initiator.id #=> String
    #   resp.initiator.display_name #=> String
    #   resp.owner.display_name #=> String
    #   resp.owner.id #=> String
    #   resp.storage_class #=> String, one of "STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA"
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListParts AWS API Documentation
    #
    # @overload list_parts(params = {})
    # @param [Hash] params ({})
    def list_parts(params = {}, options = {})
      req = build_request(:list_parts, params)
      req.send_request(options)
    end

    # Sets the accelerate configuration of an existing bucket.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket for which the accelerate configuration is set.
    #
    # @option params [required, Types::AccelerateConfiguration] :accelerate_configuration
    #   Specifies the Accelerate Configuration you want to set for the bucket.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_accelerate_configuration({
    #     bucket: "BucketName", # required
    #     accelerate_configuration: { # required
    #       status: "Enabled", # accepts Enabled, Suspended
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketAccelerateConfiguration AWS API Documentation
    #
    # @overload put_bucket_accelerate_configuration(params = {})
    # @param [Hash] params ({})
    def put_bucket_accelerate_configuration(params = {}, options = {})
      req = build_request(:put_bucket_accelerate_configuration, params)
      req.send_request(options)
    end

    # Sets the permissions on a bucket using access control lists (ACL).
    #
    # @option params [String] :acl
    #   The canned ACL to apply to the bucket.
    #
    # @option params [Types::AccessControlPolicy] :access_control_policy
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [String] :grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions on
    #   the bucket.
    #
    # @option params [String] :grant_read
    #   Allows grantee to list the objects in the bucket.
    #
    # @option params [String] :grant_read_acp
    #   Allows grantee to read the bucket ACL.
    #
    # @option params [String] :grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    #
    # @option params [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Put bucket acl
    #
    #   # The following example replaces existing ACL on a bucket. The ACL grants the bucket owner (specified using the owner ID)
    #   # and write permission to the LogDelivery group. Because this is a replace operation, you must specify all the grants in
    #   # your request. To incrementally add or remove ACL grants, you might use the console.
    #
    #   resp = client.put_bucket_acl({
    #     bucket: "examplebucket", 
    #     grant_full_control: "id=examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484", 
    #     grant_write: "uri=http://acs.amazonaws.com/groups/s3/LogDelivery", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_acl({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #     access_control_policy: {
    #       grants: [
    #         {
    #           grantee: {
    #             display_name: "DisplayName",
    #             email_address: "EmailAddress",
    #             id: "ID",
    #             type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #             uri: "URI",
    #           },
    #           permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #         },
    #       ],
    #       owner: {
    #         display_name: "DisplayName",
    #         id: "ID",
    #       },
    #     },
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write: "GrantWrite",
    #     grant_write_acp: "GrantWriteACP",
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketAcl AWS API Documentation
    #
    # @overload put_bucket_acl(params = {})
    # @param [Hash] params ({})
    def put_bucket_acl(params = {}, options = {})
      req = build_request(:put_bucket_acl, params)
      req.send_request(options)
    end

    # Sets an analytics configuration for the bucket (specified by the
    # analytics configuration ID).
    #
    # @option params [required, String] :bucket
    #   The name of the bucket to which an analytics configuration is stored.
    #
    # @option params [required, String] :id
    #   The identifier used to represent an analytics configuration.
    #
    # @option params [required, Types::AnalyticsConfiguration] :analytics_configuration
    #   The configuration and any analyses for the analytics filter.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_analytics_configuration({
    #     bucket: "BucketName", # required
    #     id: "AnalyticsId", # required
    #     analytics_configuration: { # required
    #       id: "AnalyticsId", # required
    #       filter: {
    #         prefix: "Prefix",
    #         tag: {
    #           key: "ObjectKey", # required
    #           value: "Value", # required
    #         },
    #         and: {
    #           prefix: "Prefix",
    #           tags: [
    #             {
    #               key: "ObjectKey", # required
    #               value: "Value", # required
    #             },
    #           ],
    #         },
    #       },
    #       storage_class_analysis: { # required
    #         data_export: {
    #           output_schema_version: "V_1", # required, accepts V_1
    #           destination: { # required
    #             s3_bucket_destination: { # required
    #               format: "CSV", # required, accepts CSV
    #               bucket_account_id: "AccountId",
    #               bucket: "BucketName", # required
    #               prefix: "Prefix",
    #             },
    #           },
    #         },
    #       },
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketAnalyticsConfiguration AWS API Documentation
    #
    # @overload put_bucket_analytics_configuration(params = {})
    # @param [Hash] params ({})
    def put_bucket_analytics_configuration(params = {}, options = {})
      req = build_request(:put_bucket_analytics_configuration, params)
      req.send_request(options)
    end

    # Sets the cors configuration for a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, Types::CORSConfiguration] :cors_configuration
    #
    # @option params [String] :content_md5
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: To set cors configuration on a bucket.
    #
    #   # The following example enables PUT, POST, and DELETE requests from www.example.com, and enables GET requests from any
    #   # domain.
    #
    #   resp = client.put_bucket_cors({
    #     bucket: "", 
    #     cors_configuration: {
    #       cors_rules: [
    #         {
    #           allowed_headers: [
    #             "*", 
    #           ], 
    #           allowed_methods: [
    #             "PUT", 
    #             "POST", 
    #             "DELETE", 
    #           ], 
    #           allowed_origins: [
    #             "http://www.example.com", 
    #           ], 
    #           expose_headers: [
    #             "x-amz-server-side-encryption", 
    #           ], 
    #           max_age_seconds: 3000, 
    #         }, 
    #         {
    #           allowed_headers: [
    #             "Authorization", 
    #           ], 
    #           allowed_methods: [
    #             "GET", 
    #           ], 
    #           allowed_origins: [
    #             "*", 
    #           ], 
    #           max_age_seconds: 3000, 
    #         }, 
    #       ], 
    #     }, 
    #     content_md5: "", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_cors({
    #     bucket: "BucketName", # required
    #     cors_configuration: { # required
    #       cors_rules: [ # required
    #         {
    #           allowed_headers: ["AllowedHeader"],
    #           allowed_methods: ["AllowedMethod"], # required
    #           allowed_origins: ["AllowedOrigin"], # required
    #           expose_headers: ["ExposeHeader"],
    #           max_age_seconds: 1,
    #         },
    #       ],
    #     },
    #     content_md5: "ContentMD5",
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketCors AWS API Documentation
    #
    # @overload put_bucket_cors(params = {})
    # @param [Hash] params ({})
    def put_bucket_cors(params = {}, options = {})
      req = build_request(:put_bucket_cors, params)
      req.send_request(options)
    end

    # Creates a new server-side encryption configuration (or replaces an
    # existing one, if present).
    #
    # @option params [required, String] :bucket
    #   The name of the bucket for which the server-side encryption
    #   configuration is set.
    #
    # @option params [String] :content_md5
    #   The base64-encoded 128-bit MD5 digest of the server-side encryption
    #   configuration.
    #
    # @option params [required, Types::ServerSideEncryptionConfiguration] :server_side_encryption_configuration
    #   Container for server-side encryption configuration rules. Currently S3
    #   supports one rule only.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_encryption({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     server_side_encryption_configuration: { # required
    #       rules: [ # required
    #         {
    #           apply_server_side_encryption_by_default: {
    #             sse_algorithm: "AES256", # required, accepts AES256, aws:kms
    #             kms_master_key_id: "SSEKMSKeyId",
    #           },
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketEncryption AWS API Documentation
    #
    # @overload put_bucket_encryption(params = {})
    # @param [Hash] params ({})
    def put_bucket_encryption(params = {}, options = {})
      req = build_request(:put_bucket_encryption, params)
      req.send_request(options)
    end

    # Adds an inventory configuration (identified by the inventory ID) from
    # the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket where the inventory configuration will be
    #   stored.
    #
    # @option params [required, String] :id
    #   The ID used to identify the inventory configuration.
    #
    # @option params [required, Types::InventoryConfiguration] :inventory_configuration
    #   Specifies the inventory configuration.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_inventory_configuration({
    #     bucket: "BucketName", # required
    #     id: "InventoryId", # required
    #     inventory_configuration: { # required
    #       destination: { # required
    #         s3_bucket_destination: { # required
    #           account_id: "AccountId",
    #           bucket: "BucketName", # required
    #           format: "CSV", # required, accepts CSV, ORC
    #           prefix: "Prefix",
    #           encryption: {
    #             sses3: {
    #             },
    #             ssekms: {
    #               key_id: "SSEKMSKeyId", # required
    #             },
    #           },
    #         },
    #       },
    #       is_enabled: false, # required
    #       filter: {
    #         prefix: "Prefix", # required
    #       },
    #       id: "InventoryId", # required
    #       included_object_versions: "All", # required, accepts All, Current
    #       optional_fields: ["Size"], # accepts Size, LastModifiedDate, StorageClass, ETag, IsMultipartUploaded, ReplicationStatus, EncryptionStatus
    #       schedule: { # required
    #         frequency: "Daily", # required, accepts Daily, Weekly
    #       },
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketInventoryConfiguration AWS API Documentation
    #
    # @overload put_bucket_inventory_configuration(params = {})
    # @param [Hash] params ({})
    def put_bucket_inventory_configuration(params = {}, options = {})
      req = build_request(:put_bucket_inventory_configuration, params)
      req.send_request(options)
    end

    # Deprecated, see the PutBucketLifecycleConfiguration operation.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [Types::LifecycleConfiguration] :lifecycle_configuration
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_lifecycle({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     lifecycle_configuration: {
    #       rules: [ # required
    #         {
    #           expiration: {
    #             date: Time.now,
    #             days: 1,
    #             expired_object_delete_marker: false,
    #           },
    #           id: "ID",
    #           prefix: "Prefix", # required
    #           status: "Enabled", # required, accepts Enabled, Disabled
    #           transition: {
    #             date: Time.now,
    #             days: 1,
    #             storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #           },
    #           noncurrent_version_transition: {
    #             noncurrent_days: 1,
    #             storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #           },
    #           noncurrent_version_expiration: {
    #             noncurrent_days: 1,
    #           },
    #           abort_incomplete_multipart_upload: {
    #             days_after_initiation: 1,
    #           },
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketLifecycle AWS API Documentation
    #
    # @overload put_bucket_lifecycle(params = {})
    # @param [Hash] params ({})
    def put_bucket_lifecycle(params = {}, options = {})
      req = build_request(:put_bucket_lifecycle, params)
      req.send_request(options)
    end

    # Sets lifecycle configuration for your bucket. If a lifecycle
    # configuration exists, it replaces it.
    #
    # @option params [required, String] :bucket
    #
    # @option params [Types::BucketLifecycleConfiguration] :lifecycle_configuration
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Put bucket lifecycle
    #
    #   # The following example replaces existing lifecycle configuration, if any, on the specified bucket. 
    #
    #   resp = client.put_bucket_lifecycle_configuration({
    #     bucket: "examplebucket", 
    #     lifecycle_configuration: {
    #       rules: [
    #         {
    #           expiration: {
    #             days: 3650, 
    #           }, 
    #           filter: {
    #             prefix: "documents/", 
    #           }, 
    #           id: "TestOnly", 
    #           status: "Enabled", 
    #           transitions: [
    #             {
    #               days: 365, 
    #               storage_class: "GLACIER", 
    #             }, 
    #           ], 
    #         }, 
    #       ], 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_lifecycle_configuration({
    #     bucket: "BucketName", # required
    #     lifecycle_configuration: {
    #       rules: [ # required
    #         {
    #           expiration: {
    #             date: Time.now,
    #             days: 1,
    #             expired_object_delete_marker: false,
    #           },
    #           id: "ID",
    #           prefix: "Prefix",
    #           filter: {
    #             prefix: "Prefix",
    #             tag: {
    #               key: "ObjectKey", # required
    #               value: "Value", # required
    #             },
    #             and: {
    #               prefix: "Prefix",
    #               tags: [
    #                 {
    #                   key: "ObjectKey", # required
    #                   value: "Value", # required
    #                 },
    #               ],
    #             },
    #           },
    #           status: "Enabled", # required, accepts Enabled, Disabled
    #           transitions: [
    #             {
    #               date: Time.now,
    #               days: 1,
    #               storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #             },
    #           ],
    #           noncurrent_version_transitions: [
    #             {
    #               noncurrent_days: 1,
    #               storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #             },
    #           ],
    #           noncurrent_version_expiration: {
    #             noncurrent_days: 1,
    #           },
    #           abort_incomplete_multipart_upload: {
    #             days_after_initiation: 1,
    #           },
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketLifecycleConfiguration AWS API Documentation
    #
    # @overload put_bucket_lifecycle_configuration(params = {})
    # @param [Hash] params ({})
    def put_bucket_lifecycle_configuration(params = {}, options = {})
      req = build_request(:put_bucket_lifecycle_configuration, params)
      req.send_request(options)
    end

    # Set the logging parameters for a bucket and to specify permissions for
    # who can view and modify the logging parameters. To set the logging
    # status of a bucket, you must be the bucket owner.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, Types::BucketLoggingStatus] :bucket_logging_status
    #
    # @option params [String] :content_md5
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set logging configuration for a bucket
    #
    #   # The following example sets logging policy on a bucket. For the Log Delivery group to deliver logs to the destination
    #   # bucket, it needs permission for the READ_ACP action which the policy grants.
    #
    #   resp = client.put_bucket_logging({
    #     bucket: "sourcebucket", 
    #     bucket_logging_status: {
    #       logging_enabled: {
    #         target_bucket: "targetbucket", 
    #         target_grants: [
    #           {
    #             grantee: {
    #               type: "Group", 
    #               uri: "http://acs.amazonaws.com/groups/global/AllUsers", 
    #             }, 
    #             permission: "READ", 
    #           }, 
    #         ], 
    #         target_prefix: "MyBucketLogs/", 
    #       }, 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_logging({
    #     bucket: "BucketName", # required
    #     bucket_logging_status: { # required
    #       logging_enabled: {
    #         target_bucket: "TargetBucket", # required
    #         target_grants: [
    #           {
    #             grantee: {
    #               display_name: "DisplayName",
    #               email_address: "EmailAddress",
    #               id: "ID",
    #               type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #               uri: "URI",
    #             },
    #             permission: "FULL_CONTROL", # accepts FULL_CONTROL, READ, WRITE
    #           },
    #         ],
    #         target_prefix: "TargetPrefix", # required
    #       },
    #     },
    #     content_md5: "ContentMD5",
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketLogging AWS API Documentation
    #
    # @overload put_bucket_logging(params = {})
    # @param [Hash] params ({})
    def put_bucket_logging(params = {}, options = {})
      req = build_request(:put_bucket_logging, params)
      req.send_request(options)
    end

    # Sets a metrics configuration (specified by the metrics configuration
    # ID) for the bucket.
    #
    # @option params [required, String] :bucket
    #   The name of the bucket for which the metrics configuration is set.
    #
    # @option params [required, String] :id
    #   The ID used to identify the metrics configuration.
    #
    # @option params [required, Types::MetricsConfiguration] :metrics_configuration
    #   Specifies the metrics configuration.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_metrics_configuration({
    #     bucket: "BucketName", # required
    #     id: "MetricsId", # required
    #     metrics_configuration: { # required
    #       id: "MetricsId", # required
    #       filter: {
    #         prefix: "Prefix",
    #         tag: {
    #           key: "ObjectKey", # required
    #           value: "Value", # required
    #         },
    #         and: {
    #           prefix: "Prefix",
    #           tags: [
    #             {
    #               key: "ObjectKey", # required
    #               value: "Value", # required
    #             },
    #           ],
    #         },
    #       },
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketMetricsConfiguration AWS API Documentation
    #
    # @overload put_bucket_metrics_configuration(params = {})
    # @param [Hash] params ({})
    def put_bucket_metrics_configuration(params = {}, options = {})
      req = build_request(:put_bucket_metrics_configuration, params)
      req.send_request(options)
    end

    # Deprecated, see the PutBucketNotificationConfiguraiton operation.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [required, Types::NotificationConfigurationDeprecated] :notification_configuration
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_notification({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     notification_configuration: { # required
    #       topic_configuration: {
    #         id: "NotificationId",
    #         events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         topic: "TopicArn",
    #       },
    #       queue_configuration: {
    #         id: "NotificationId",
    #         event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         queue: "QueueArn",
    #       },
    #       cloud_function_configuration: {
    #         id: "NotificationId",
    #         event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         cloud_function: "CloudFunction",
    #         invocation_role: "CloudFunctionInvocationRole",
    #       },
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketNotification AWS API Documentation
    #
    # @overload put_bucket_notification(params = {})
    # @param [Hash] params ({})
    def put_bucket_notification(params = {}, options = {})
      req = build_request(:put_bucket_notification, params)
      req.send_request(options)
    end

    # Enables notifications of specified events for a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, Types::NotificationConfiguration] :notification_configuration
    #   Container for specifying the notification configuration of the bucket.
    #   If this element is empty, notifications are turned off on the bucket.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set notification configuration for a bucket
    #
    #   # The following example sets notification configuration on a bucket to publish the object created events to an SNS topic.
    #
    #   resp = client.put_bucket_notification_configuration({
    #     bucket: "examplebucket", 
    #     notification_configuration: {
    #       topic_configurations: [
    #         {
    #           events: [
    #             "s3:ObjectCreated:*", 
    #           ], 
    #           topic_arn: "arn:aws:sns:us-west-2:123456789012:s3-notification-topic", 
    #         }, 
    #       ], 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_notification_configuration({
    #     bucket: "BucketName", # required
    #     notification_configuration: { # required
    #       topic_configurations: [
    #         {
    #           id: "NotificationId",
    #           topic_arn: "TopicArn", # required
    #           events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           filter: {
    #             key: {
    #               filter_rules: [
    #                 {
    #                   name: "prefix", # accepts prefix, suffix
    #                   value: "FilterRuleValue",
    #                 },
    #               ],
    #             },
    #           },
    #         },
    #       ],
    #       queue_configurations: [
    #         {
    #           id: "NotificationId",
    #           queue_arn: "QueueArn", # required
    #           events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           filter: {
    #             key: {
    #               filter_rules: [
    #                 {
    #                   name: "prefix", # accepts prefix, suffix
    #                   value: "FilterRuleValue",
    #                 },
    #               ],
    #             },
    #           },
    #         },
    #       ],
    #       lambda_function_configurations: [
    #         {
    #           id: "NotificationId",
    #           lambda_function_arn: "LambdaFunctionArn", # required
    #           events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           filter: {
    #             key: {
    #               filter_rules: [
    #                 {
    #                   name: "prefix", # accepts prefix, suffix
    #                   value: "FilterRuleValue",
    #                 },
    #               ],
    #             },
    #           },
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketNotificationConfiguration AWS API Documentation
    #
    # @overload put_bucket_notification_configuration(params = {})
    # @param [Hash] params ({})
    def put_bucket_notification_configuration(params = {}, options = {})
      req = build_request(:put_bucket_notification_configuration, params)
      req.send_request(options)
    end

    # Replaces a policy on a bucket. If the bucket already has a policy, the
    # one in this request completely replaces it.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [Boolean] :confirm_remove_self_bucket_access
    #   Set this parameter to true to confirm that you want to remove your
    #   permissions to change this bucket policy in the future.
    #
    # @option params [required, String] :policy
    #   The bucket policy as a JSON document.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set bucket policy
    #
    #   # The following example sets a permission policy on a bucket.
    #
    #   resp = client.put_bucket_policy({
    #     bucket: "examplebucket", 
    #     policy: "{\"Version\": \"2012-10-17\", \"Statement\": [{ \"Sid\": \"id-1\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"arn:aws:iam::123456789012:root\"}, \"Action\": [ \"s3:PutObject\",\"s3:PutObjectAcl\"], \"Resource\": [\"arn:aws:s3:::acl3/*\" ] } ]}", 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_policy({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     confirm_remove_self_bucket_access: false,
    #     policy: "Policy", # required
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketPolicy AWS API Documentation
    #
    # @overload put_bucket_policy(params = {})
    # @param [Hash] params ({})
    def put_bucket_policy(params = {}, options = {})
      req = build_request(:put_bucket_policy, params)
      req.send_request(options)
    end

    # Creates a new replication configuration (or replaces an existing one,
    # if present).
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [required, Types::ReplicationConfiguration] :replication_configuration
    #   Container for replication rules. You can add as many as 1,000 rules.
    #   Total replication configuration size can be up to 2 MB.
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set replication configuration on a bucket
    #
    #   # The following example sets replication configuration on a bucket.
    #
    #   resp = client.put_bucket_replication({
    #     bucket: "examplebucket", 
    #     replication_configuration: {
    #       role: "arn:aws:iam::123456789012:role/examplerole", 
    #       rules: [
    #         {
    #           destination: {
    #             bucket: "arn:aws:s3:::destinationbucket", 
    #             storage_class: "STANDARD", 
    #           }, 
    #           prefix: "", 
    #           status: "Enabled", 
    #         }, 
    #       ], 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_replication({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     replication_configuration: { # required
    #       role: "Role", # required
    #       rules: [ # required
    #         {
    #           id: "ID",
    #           prefix: "Prefix", # required
    #           status: "Enabled", # required, accepts Enabled, Disabled
    #           source_selection_criteria: {
    #             sse_kms_encrypted_objects: {
    #               status: "Enabled", # required, accepts Enabled, Disabled
    #             },
    #           },
    #           destination: { # required
    #             bucket: "BucketName", # required
    #             account: "AccountId",
    #             storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #             access_control_translation: {
    #               owner: "Destination", # required, accepts Destination
    #             },
    #             encryption_configuration: {
    #               replica_kms_key_id: "ReplicaKmsKeyID",
    #             },
    #           },
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketReplication AWS API Documentation
    #
    # @overload put_bucket_replication(params = {})
    # @param [Hash] params ({})
    def put_bucket_replication(params = {}, options = {})
      req = build_request(:put_bucket_replication, params)
      req.send_request(options)
    end

    # Sets the request payment configuration for a bucket. By default, the
    # bucket owner pays for downloads from the bucket. This configuration
    # parameter enables the bucket owner (only) to specify that the person
    # requesting the download will be charged for the download.
    # Documentation on requester pays buckets can be found at
    # http://docs.aws.amazon.com/AmazonS3/latest/dev/RequesterPaysBuckets.html
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [required, Types::RequestPaymentConfiguration] :request_payment_configuration
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set request payment configuration on a bucket.
    #
    #   # The following example sets request payment configuration on a bucket so that person requesting the download is charged.
    #
    #   resp = client.put_bucket_request_payment({
    #     bucket: "examplebucket", 
    #     request_payment_configuration: {
    #       payer: "Requester", 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_request_payment({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     request_payment_configuration: { # required
    #       payer: "Requester", # required, accepts Requester, BucketOwner
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketRequestPayment AWS API Documentation
    #
    # @overload put_bucket_request_payment(params = {})
    # @param [Hash] params ({})
    def put_bucket_request_payment(params = {}, options = {})
      req = build_request(:put_bucket_request_payment, params)
      req.send_request(options)
    end

    # Sets the tags for a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [required, Types::Tagging] :tagging
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set tags on a bucket
    #
    #   # The following example sets tags on a bucket. Any existing tags are replaced.
    #
    #   resp = client.put_bucket_tagging({
    #     bucket: "examplebucket", 
    #     tagging: {
    #       tag_set: [
    #         {
    #           key: "Key1", 
    #           value: "Value1", 
    #         }, 
    #         {
    #           key: "Key2", 
    #           value: "Value2", 
    #         }, 
    #       ], 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_tagging({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     tagging: { # required
    #       tag_set: [ # required
    #         {
    #           key: "ObjectKey", # required
    #           value: "Value", # required
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketTagging AWS API Documentation
    #
    # @overload put_bucket_tagging(params = {})
    # @param [Hash] params ({})
    def put_bucket_tagging(params = {}, options = {})
      req = build_request(:put_bucket_tagging, params)
      req.send_request(options)
    end

    # Sets the versioning state of an existing bucket. To set the versioning
    # state, you must be the bucket owner.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [String] :mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication device.
    #
    # @option params [required, Types::VersioningConfiguration] :versioning_configuration
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set versioning configuration on a bucket
    #
    #   # The following example sets versioning configuration on bucket. The configuration enables versioning on the bucket.
    #
    #   resp = client.put_bucket_versioning({
    #     bucket: "examplebucket", 
    #     versioning_configuration: {
    #       mfa_delete: "Disabled", 
    #       status: "Enabled", 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_versioning({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     mfa: "MFA",
    #     versioning_configuration: { # required
    #       mfa_delete: "Enabled", # accepts Enabled, Disabled
    #       status: "Enabled", # accepts Enabled, Suspended
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketVersioning AWS API Documentation
    #
    # @overload put_bucket_versioning(params = {})
    # @param [Hash] params ({})
    def put_bucket_versioning(params = {}, options = {})
      req = build_request(:put_bucket_versioning, params)
      req.send_request(options)
    end

    # Set the website configuration for a bucket.
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [required, Types::WebsiteConfiguration] :website_configuration
    #
    # @return [Struct] Returns an empty {Seahorse::Client::Response response}.
    #
    #
    # @example Example: Set website configuration on a bucket
    #
    #   # The following example adds website configuration to a bucket.
    #
    #   resp = client.put_bucket_website({
    #     bucket: "examplebucket", 
    #     content_md5: "", 
    #     website_configuration: {
    #       error_document: {
    #         key: "error.html", 
    #       }, 
    #       index_document: {
    #         suffix: "index.html", 
    #       }, 
    #     }, 
    #   })
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_bucket_website({
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     website_configuration: { # required
    #       error_document: {
    #         key: "ObjectKey", # required
    #       },
    #       index_document: {
    #         suffix: "Suffix", # required
    #       },
    #       redirect_all_requests_to: {
    #         host_name: "HostName", # required
    #         protocol: "http", # accepts http, https
    #       },
    #       routing_rules: [
    #         {
    #           condition: {
    #             http_error_code_returned_equals: "HttpErrorCodeReturnedEquals",
    #             key_prefix_equals: "KeyPrefixEquals",
    #           },
    #           redirect: { # required
    #             host_name: "HostName",
    #             http_redirect_code: "HttpRedirectCode",
    #             protocol: "http", # accepts http, https
    #             replace_key_prefix_with: "ReplaceKeyPrefixWith",
    #             replace_key_with: "ReplaceKeyWith",
    #           },
    #         },
    #       ],
    #     },
    #   })
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketWebsite AWS API Documentation
    #
    # @overload put_bucket_website(params = {})
    # @param [Hash] params ({})
    def put_bucket_website(params = {}, options = {})
      req = build_request(:put_bucket_website, params)
      req.send_request(options)
    end

    # Adds an object to a bucket.
    #
    # @option params [String] :acl
    #   The canned ACL to apply to the object.
    #
    # @option params [String, IO] :body
    #   Object data.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket to which the PUT operation was initiated.
    #
    # @option params [String] :cache_control
    #   Specifies caching behavior along the request/reply chain.
    #
    # @option params [String] :content_disposition
    #   Specifies presentational information for the object.
    #
    # @option params [String] :content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the media-type
    #   referenced by the Content-Type header field.
    #
    # @option params [String] :content_language
    #   The language the content is in.
    #
    # @option params [Integer] :content_length
    #   Size of the body in bytes. This parameter is useful when the size of
    #   the body cannot be determined automatically.
    #
    # @option params [String] :content_md5
    #   The base64-encoded 128-bit MD5 digest of the part data.
    #
    # @option params [String] :content_type
    #   A standard MIME type describing the format of the object data.
    #
    # @option params [Time,DateTime,Date,Integer,String] :expires
    #   The date and time at which the object is no longer cacheable.
    #
    # @option params [String] :grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    #
    # @option params [String] :grant_read
    #   Allows grantee to read the object data and its metadata.
    #
    # @option params [String] :grant_read_acp
    #   Allows grantee to read the object ACL.
    #
    # @option params [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    #
    # @option params [required, String] :key
    #   Object key for which the PUT operation was initiated.
    #
    # @option params [Hash<String,String>] :metadata
    #   A map of metadata to store with the object in S3.
    #
    # @option params [String] :server_side_encryption
    #   The Server-side encryption algorithm used when storing this object in
    #   S3 (e.g., AES256, aws:kms).
    #
    # @option params [String] :storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    #
    # @option params [String] :website_redirect_location
    #   If the bucket is configured as a website, redirects requests for this
    #   object to another object in the same bucket or to an external URL.
    #   Amazon S3 stores the value of this header in the object metadata.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET and
    #   PUT requests for an object protected by AWS KMS will fail if not made
    #   via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @option params [String] :tagging
    #   The tag-set for the object. The tag-set must be encoded as URL Query
    #   parameters
    #
    # @return [Types::PutObjectOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::PutObjectOutput#expiration #expiration} => String
    #   * {Types::PutObjectOutput#etag #etag} => String
    #   * {Types::PutObjectOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::PutObjectOutput#version_id #version_id} => String
    #   * {Types::PutObjectOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::PutObjectOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::PutObjectOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::PutObjectOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To upload an object and specify server-side encryption and object tags
    #
    #   # The following example uploads and object. The request specifies the optional server-side encryption option. The request
    #   # also specifies optional object tags. If the bucket is versioning enabled, S3 returns version ID in response.
    #
    #   resp = client.put_object({
    #     body: "filetoupload", 
    #     bucket: "examplebucket", 
    #     key: "exampleobject", 
    #     server_side_encryption: "AES256", 
    #     tagging: "key1=value1&key2=value2", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     server_side_encryption: "AES256", 
    #     version_id: "Ri.vC6qVlA4dEnjgRV4ZHsHoFIjqEMNt", 
    #   }
    #
    # @example Example: To upload an object and specify canned ACL.
    #
    #   # The following example uploads and object. The request specifies optional canned ACL (access control list) to all READ
    #   # access to authenticated users. If the bucket is versioning enabled, S3 returns version ID in response.
    #
    #   resp = client.put_object({
    #     acl: "authenticated-read", 
    #     body: "filetoupload", 
    #     bucket: "examplebucket", 
    #     key: "exampleobject", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     version_id: "Kirh.unyZwjQ69YxcQLA8z4F5j3kJJKr", 
    #   }
    #
    # @example Example: To upload an object
    #
    #   # The following example uploads an object to a versioning-enabled bucket. The source file is specified using Windows file
    #   # syntax. S3 returns VersionId of the newly created object.
    #
    #   resp = client.put_object({
    #     body: "HappyFace.jpg", 
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     version_id: "tpf3zF08nBplQK1XLOefGskR7mGDwcDk", 
    #   }
    #
    # @example Example: To create an object.
    #
    #   # The following example creates an object. If the bucket is versioning enabled, S3 returns version ID in response.
    #
    #   resp = client.put_object({
    #     body: "filetoupload", 
    #     bucket: "examplebucket", 
    #     key: "objectkey", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     version_id: "Bvq0EDKxOcXLJXNo_Lkz37eM3R4pfzyQ", 
    #   }
    #
    # @example Example: To upload an object and specify optional tags
    #
    #   # The following example uploads an object. The request specifies optional object tags. The bucket is versioned, therefore
    #   # S3 returns version ID of the newly created object.
    #
    #   resp = client.put_object({
    #     body: "c:\\HappyFace.jpg", 
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #     tagging: "key1=value1&key2=value2", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     version_id: "psM2sYY4.o1501dSx8wMvnkOzSBB.V4a", 
    #   }
    #
    # @example Example: To upload object and specify user-defined metadata
    #
    #   # The following example creates an object. The request also specifies optional metadata. If the bucket is versioning
    #   # enabled, S3 returns version ID in response.
    #
    #   resp = client.put_object({
    #     body: "filetoupload", 
    #     bucket: "examplebucket", 
    #     key: "exampleobject", 
    #     metadata: {
    #       "metadata1" => "value1", 
    #       "metadata2" => "value2", 
    #     }, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     version_id: "pSKidl4pHBiNwukdbcPXAIs.sshFFOc0", 
    #   }
    #
    # @example Example: To upload an object (specify optional headers)
    #
    #   # The following example uploads an object. The request specifies optional request headers to directs S3 to use specific
    #   # storage class and use server-side encryption.
    #
    #   resp = client.put_object({
    #     body: "HappyFace.jpg", 
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #     server_side_encryption: "AES256", 
    #     storage_class: "STANDARD_IA", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
    #     server_side_encryption: "AES256", 
    #     version_id: "CG612hodqujkf8FaaNfp8U..FIhLROcp", 
    #   }
    #
    # @example Streaming a file from disk
    #   # upload file from disk in a single request, may not exceed 5GB
    #   File.open('/source/file/path', 'rb') do |file|
    #     s3.put_object(bucket: 'bucket-name', key: 'object-key', body: file)
    #   end
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_object({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #     body: source_file,
    #     bucket: "BucketName", # required
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
    #
    # @example Response structure
    #
    #   resp.expiration #=> String
    #   resp.etag #=> String
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.version_id #=> String
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObject AWS API Documentation
    #
    # @overload put_object(params = {})
    # @param [Hash] params ({})
    def put_object(params = {}, options = {})
      req = build_request(:put_object, params)
      req.send_request(options)
    end

    # uses the acl subresource to set the access control list (ACL)
    # permissions for an object that already exists in a bucket
    #
    # @option params [String] :acl
    #   The canned ACL to apply to the object.
    #
    # @option params [Types::AccessControlPolicy] :access_control_policy
    #
    # @option params [required, String] :bucket
    #
    # @option params [String] :content_md5
    #
    # @option params [String] :grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions on
    #   the bucket.
    #
    # @option params [String] :grant_read
    #   Allows grantee to list the objects in the bucket.
    #
    # @option params [String] :grant_read_acp
    #   Allows grantee to read the bucket ACL.
    #
    # @option params [String] :grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    #
    # @option params [String] :grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    #
    # @option params [required, String] :key
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @option params [String] :version_id
    #   VersionId used to reference a specific version of the object.
    #
    # @return [Types::PutObjectAclOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::PutObjectAclOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To grant permissions using object ACL
    #
    #   # The following example adds grants to an object ACL. The first permission grants user1 and user2 FULL_CONTROL and the
    #   # AllUsers group READ permission.
    #
    #   resp = client.put_object_acl({
    #     access_control_policy: {
    #     }, 
    #     bucket: "examplebucket", 
    #     grant_full_control: "emailaddress=user1@example.com,emailaddress=user2@example.com", 
    #     grant_read: "uri=http://acs.amazonaws.com/groups/global/AllUsers", 
    #     key: "HappyFace.jpg", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_object_acl({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #     access_control_policy: {
    #       grants: [
    #         {
    #           grantee: {
    #             display_name: "DisplayName",
    #             email_address: "EmailAddress",
    #             id: "ID",
    #             type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #             uri: "URI",
    #           },
    #           permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #         },
    #       ],
    #       owner: {
    #         display_name: "DisplayName",
    #         id: "ID",
    #       },
    #     },
    #     bucket: "BucketName", # required
    #     content_md5: "ContentMD5",
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write: "GrantWrite",
    #     grant_write_acp: "GrantWriteACP",
    #     key: "ObjectKey", # required
    #     request_payer: "requester", # accepts requester
    #     version_id: "ObjectVersionId",
    #   })
    #
    # @example Response structure
    #
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectAcl AWS API Documentation
    #
    # @overload put_object_acl(params = {})
    # @param [Hash] params ({})
    def put_object_acl(params = {}, options = {})
      req = build_request(:put_object_acl, params)
      req.send_request(options)
    end

    # Sets the supplied tag-set to an object that already exists in a bucket
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :version_id
    #
    # @option params [String] :content_md5
    #
    # @option params [required, Types::Tagging] :tagging
    #
    # @return [Types::PutObjectTaggingOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::PutObjectTaggingOutput#version_id #version_id} => String
    #
    #
    # @example Example: To add tags to an existing object
    #
    #   # The following example adds tags to an existing object.
    #
    #   resp = client.put_object_tagging({
    #     bucket: "examplebucket", 
    #     key: "HappyFace.jpg", 
    #     tagging: {
    #       tag_set: [
    #         {
    #           key: "Key3", 
    #           value: "Value3", 
    #         }, 
    #         {
    #           key: "Key4", 
    #           value: "Value4", 
    #         }, 
    #       ], 
    #     }, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     version_id: "null", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.put_object_tagging({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     version_id: "ObjectVersionId",
    #     content_md5: "ContentMD5",
    #     tagging: { # required
    #       tag_set: [ # required
    #         {
    #           key: "ObjectKey", # required
    #           value: "Value", # required
    #         },
    #       ],
    #     },
    #   })
    #
    # @example Response structure
    #
    #   resp.version_id #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectTagging AWS API Documentation
    #
    # @overload put_object_tagging(params = {})
    # @param [Hash] params ({})
    def put_object_tagging(params = {}, options = {})
      req = build_request(:put_object_tagging, params)
      req.send_request(options)
    end

    # Restores an archived copy of an object back into Amazon S3
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :key
    #
    # @option params [String] :version_id
    #
    # @option params [Types::RestoreRequest] :restore_request
    #   Container for restore job parameters.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::RestoreObjectOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::RestoreObjectOutput#request_charged #request_charged} => String
    #   * {Types::RestoreObjectOutput#restore_output_path #restore_output_path} => String
    #
    #
    # @example Example: To restore an archived object
    #
    #   # The following example restores for one day an archived copy of an object back into Amazon S3 bucket.
    #
    #   resp = client.restore_object({
    #     bucket: "examplebucket", 
    #     key: "archivedobjectkey", 
    #     restore_request: {
    #       days: 1, 
    #       glacier_job_parameters: {
    #         tier: "Expedited", 
    #       }, 
    #     }, 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.restore_object({
    #     bucket: "BucketName", # required
    #     key: "ObjectKey", # required
    #     version_id: "ObjectVersionId",
    #     restore_request: {
    #       days: 1,
    #       glacier_job_parameters: {
    #         tier: "Standard", # required, accepts Standard, Bulk, Expedited
    #       },
    #       type: "SELECT", # accepts SELECT
    #       tier: "Standard", # accepts Standard, Bulk, Expedited
    #       description: "Description",
    #       select_parameters: {
    #         input_serialization: { # required
    #           csv: {
    #             file_header_info: "USE", # accepts USE, IGNORE, NONE
    #             comments: "Comments",
    #             quote_escape_character: "QuoteEscapeCharacter",
    #             record_delimiter: "RecordDelimiter",
    #             field_delimiter: "FieldDelimiter",
    #             quote_character: "QuoteCharacter",
    #           },
    #           compression_type: "NONE", # accepts NONE, GZIP
    #           json: {
    #             type: "DOCUMENT", # accepts DOCUMENT, LINES
    #           },
    #         },
    #         expression_type: "SQL", # required, accepts SQL
    #         expression: "Expression", # required
    #         output_serialization: { # required
    #           csv: {
    #             quote_fields: "ALWAYS", # accepts ALWAYS, ASNEEDED
    #             quote_escape_character: "QuoteEscapeCharacter",
    #             record_delimiter: "RecordDelimiter",
    #             field_delimiter: "FieldDelimiter",
    #             quote_character: "QuoteCharacter",
    #           },
    #           json: {
    #             record_delimiter: "RecordDelimiter",
    #           },
    #         },
    #       },
    #       output_location: {
    #         s3: {
    #           bucket_name: "BucketName", # required
    #           prefix: "LocationPrefix", # required
    #           encryption: {
    #             encryption_type: "AES256", # required, accepts AES256, aws:kms
    #             kms_key_id: "SSEKMSKeyId",
    #             kms_context: "KMSContext",
    #           },
    #           canned_acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #           access_control_list: [
    #             {
    #               grantee: {
    #                 display_name: "DisplayName",
    #                 email_address: "EmailAddress",
    #                 id: "ID",
    #                 type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #                 uri: "URI",
    #               },
    #               permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #             },
    #           ],
    #           tagging: {
    #             tag_set: [ # required
    #               {
    #                 key: "ObjectKey", # required
    #                 value: "Value", # required
    #               },
    #             ],
    #           },
    #           user_metadata: [
    #             {
    #               name: "MetadataKey",
    #               value: "MetadataValue",
    #             },
    #           ],
    #           storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #         },
    #       },
    #     },
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.request_charged #=> String, one of "requester"
    #   resp.restore_output_path #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RestoreObject AWS API Documentation
    #
    # @overload restore_object(params = {})
    # @param [Hash] params ({})
    def restore_object(params = {}, options = {})
      req = build_request(:restore_object, params)
      req.send_request(options)
    end

    # Uploads a part in a multipart upload.
    #
    # **Note:** After you initiate multipart upload and upload one or more
    # parts, you must either complete or abort multipart upload in order to
    # stop getting charged for storage of the uploaded parts. Only after you
    # either complete or abort multipart upload, Amazon S3 frees up the
    # parts storage and stops charging you for the parts storage.
    #
    # @option params [String, IO] :body
    #   Object data.
    #
    # @option params [required, String] :bucket
    #   Name of the bucket to which the multipart upload was initiated.
    #
    # @option params [Integer] :content_length
    #   Size of the body in bytes. This parameter is useful when the size of
    #   the body cannot be determined automatically.
    #
    # @option params [String] :content_md5
    #   The base64-encoded 128-bit MD5 digest of the part data.
    #
    # @option params [required, String] :key
    #   Object key for which the multipart upload was initiated.
    #
    # @option params [required, Integer] :part_number
    #   Part number of part being uploaded. This is a positive integer between
    #   1 and 10,000.
    #
    # @option params [required, String] :upload_id
    #   Upload ID identifying the multipart upload whose part is being
    #   uploaded.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header. This must be
    #   the same encryption key specified in the initiate multipart upload
    #   request.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::UploadPartOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::UploadPartOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::UploadPartOutput#etag #etag} => String
    #   * {Types::UploadPartOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::UploadPartOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::UploadPartOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::UploadPartOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To upload a part
    #
    #   # The following example uploads part 1 of a multipart upload. The example specifies a file name for the part data. The
    #   # Upload ID is same that is returned by the initiate multipart upload.
    #
    #   resp = client.upload_part({
    #     body: "fileToUpload", 
    #     bucket: "examplebucket", 
    #     key: "examplelargeobject", 
    #     part_number: 1, 
    #     upload_id: "xadcOB_7YPBOJuoFiQ9cz4P3Pe6FIZwO4f7wN93uHsNBEw97pl5eNwzExg0LAT2dUN91cOmrEQHDsP3WA60CEg--", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     etag: "\"d8c2eafd90c266e19ab9dcacc479f8af\"", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.upload_part({
    #     body: source_file,
    #     bucket: "BucketName", # required
    #     content_length: 1,
    #     content_md5: "ContentMD5",
    #     key: "ObjectKey", # required
    #     part_number: 1, # required
    #     upload_id: "MultipartUploadId", # required
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.etag #=> String
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/UploadPart AWS API Documentation
    #
    # @overload upload_part(params = {})
    # @param [Hash] params ({})
    def upload_part(params = {}, options = {})
      req = build_request(:upload_part, params)
      req.send_request(options)
    end

    # Uploads a part by copying data from an existing object as data source.
    #
    # @option params [required, String] :bucket
    #
    # @option params [required, String] :copy_source
    #   The name of the source bucket and key name of the source object,
    #   separated by a slash (/). Must be URL-encoded.
    #
    # @option params [String] :copy_source_if_match
    #   Copies the object if its entity tag (ETag) matches the specified tag.
    #
    # @option params [Time,DateTime,Date,Integer,String] :copy_source_if_modified_since
    #   Copies the object if it has been modified since the specified time.
    #
    # @option params [String] :copy_source_if_none_match
    #   Copies the object if its entity tag (ETag) is different than the
    #   specified ETag.
    #
    # @option params [Time,DateTime,Date,Integer,String] :copy_source_if_unmodified_since
    #   Copies the object if it hasn't been modified since the specified
    #   time.
    #
    # @option params [String] :copy_source_range
    #   The range of bytes to copy from the source object. The range value
    #   must use the form bytes=first-last, where the first and last are the
    #   zero-based byte offsets to copy. For example, bytes=0-9 indicates that
    #   you want to copy the first ten bytes of the source. You can copy a
    #   range only if the source object is greater than 5 GB.
    #
    # @option params [required, String] :key
    #
    # @option params [required, Integer] :part_number
    #   Part number of part being copied. This is a positive integer between 1
    #   and 10,000.
    #
    # @option params [required, String] :upload_id
    #   Upload ID identifying the multipart upload whose part is being copied.
    #
    # @option params [String] :sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #
    # @option params [String] :sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use in
    #   encrypting data. This value is used to store the object and then it is
    #   discarded; Amazon does not store the encryption key. The key must be
    #   appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header. This must be
    #   the same encryption key specified in the initiate multipart upload
    #   request.
    #
    # @option params [String] :sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :copy_source_sse_customer_algorithm
    #   Specifies the algorithm to use when decrypting the source object
    #   (e.g., AES256).
    #
    # @option params [String] :copy_source_sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use to
    #   decrypt the source object. The encryption key provided in this header
    #   must be one that was used when the source object was created.
    #
    # @option params [String] :copy_source_sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check to
    #   ensure the encryption key was transmitted without error.
    #
    # @option params [String] :request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #
    # @return [Types::UploadPartCopyOutput] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::UploadPartCopyOutput#copy_source_version_id #copy_source_version_id} => String
    #   * {Types::UploadPartCopyOutput#copy_part_result #copy_part_result} => Types::CopyPartResult
    #   * {Types::UploadPartCopyOutput#server_side_encryption #server_side_encryption} => String
    #   * {Types::UploadPartCopyOutput#sse_customer_algorithm #sse_customer_algorithm} => String
    #   * {Types::UploadPartCopyOutput#sse_customer_key_md5 #sse_customer_key_md5} => String
    #   * {Types::UploadPartCopyOutput#ssekms_key_id #ssekms_key_id} => String
    #   * {Types::UploadPartCopyOutput#request_charged #request_charged} => String
    #
    #
    # @example Example: To upload a part by copying byte range from an existing object as data source
    #
    #   # The following example uploads a part of a multipart upload by copying a specified byte range from an existing object as
    #   # data source.
    #
    #   resp = client.upload_part_copy({
    #     bucket: "examplebucket", 
    #     copy_source: "/bucketname/sourceobjectkey", 
    #     copy_source_range: "bytes=1-100000", 
    #     key: "examplelargeobject", 
    #     part_number: 2, 
    #     upload_id: "exampleuoh_10OhKhT7YukE9bjzTPRiuaCotmZM_pFngJFir9OZNrSr5cWa3cq3LZSUsfjI4FI7PkP91We7Nrw--", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     copy_part_result: {
    #       etag: "\"65d16d19e65a7508a51f043180edcc36\"", 
    #       last_modified: Time.parse("2016-12-29T21:44:28.000Z"), 
    #     }, 
    #   }
    #
    # @example Example: To upload a part by copying data from an existing object as data source
    #
    #   # The following example uploads a part of a multipart upload by copying data from an existing object as data source.
    #
    #   resp = client.upload_part_copy({
    #     bucket: "examplebucket", 
    #     copy_source: "/bucketname/sourceobjectkey", 
    #     key: "examplelargeobject", 
    #     part_number: 1, 
    #     upload_id: "exampleuoh_10OhKhT7YukE9bjzTPRiuaCotmZM_pFngJFir9OZNrSr5cWa3cq3LZSUsfjI4FI7PkP91We7Nrw--", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     copy_part_result: {
    #       etag: "\"b0c6f0e7e054ab8fa2536a2677f8734d\"", 
    #       last_modified: Time.parse("2016-12-29T21:24:43.000Z"), 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.upload_part_copy({
    #     bucket: "BucketName", # required
    #     copy_source: "CopySource", # required
    #     copy_source_if_match: "CopySourceIfMatch",
    #     copy_source_if_modified_since: Time.now,
    #     copy_source_if_none_match: "CopySourceIfNoneMatch",
    #     copy_source_if_unmodified_since: Time.now,
    #     copy_source_range: "CopySourceRange",
    #     key: "ObjectKey", # required
    #     part_number: 1, # required
    #     upload_id: "MultipartUploadId", # required
    #     sse_customer_algorithm: "SSECustomerAlgorithm",
    #     sse_customer_key: "SSECustomerKey",
    #     sse_customer_key_md5: "SSECustomerKeyMD5",
    #     copy_source_sse_customer_algorithm: "CopySourceSSECustomerAlgorithm",
    #     copy_source_sse_customer_key: "CopySourceSSECustomerKey",
    #     copy_source_sse_customer_key_md5: "CopySourceSSECustomerKeyMD5",
    #     request_payer: "requester", # accepts requester
    #   })
    #
    # @example Response structure
    #
    #   resp.copy_source_version_id #=> String
    #   resp.copy_part_result.etag #=> String
    #   resp.copy_part_result.last_modified #=> Time
    #   resp.server_side_encryption #=> String, one of "AES256", "aws:kms"
    #   resp.sse_customer_algorithm #=> String
    #   resp.sse_customer_key_md5 #=> String
    #   resp.ssekms_key_id #=> String
    #   resp.request_charged #=> String, one of "requester"
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/UploadPartCopy AWS API Documentation
    #
    # @overload upload_part_copy(params = {})
    # @param [Hash] params ({})
    def upload_part_copy(params = {}, options = {})
      req = build_request(:upload_part_copy, params)
      req.send_request(options)
    end

    # @!endgroup

    # @param params ({})
    # @api private
    def build_request(operation_name, params = {})
      handlers = @handlers.for(operation_name)
      context = Seahorse::Client::RequestContext.new(
        operation_name: operation_name,
        operation: config.api.operation(operation_name),
        client: self,
        params: params,
        config: config)
      context[:gem_name] = 'aws-sdk-s3'
      context[:gem_version] = '1.9.0'
      Seahorse::Client::Request.new(handlers, context)
    end

    # Polls an API operation until a resource enters a desired state.
    #
    # ## Basic Usage
    #
    # A waiter will call an API operation until:
    #
    # * It is successful
    # * It enters a terminal state
    # * It makes the maximum number of attempts
    #
    # In between attempts, the waiter will sleep.
    #
    #     # polls in a loop, sleeping between attempts
    #     client.waiter_until(waiter_name, params)
    #
    # ## Configuration
    #
    # You can configure the maximum number of polling attempts, and the
    # delay (in seconds) between each polling attempt. You can pass
    # configuration as the final arguments hash.
    #
    #     # poll for ~25 seconds
    #     client.wait_until(waiter_name, params, {
    #       max_attempts: 5,
    #       delay: 5,
    #     })
    #
    # ## Callbacks
    #
    # You can be notified before each polling attempt and before each
    # delay. If you throw `:success` or `:failure` from these callbacks,
    # it will terminate the waiter.
    #
    #     started_at = Time.now
    #     client.wait_until(waiter_name, params, {
    #
    #       # disable max attempts
    #       max_attempts: nil,
    #
    #       # poll for 1 hour, instead of a number of attempts
    #       before_wait: -> (attempts, response) do
    #         throw :failure if Time.now - started_at > 3600
    #       end
    #     })
    #
    # ## Handling Errors
    #
    # When a waiter is unsuccessful, it will raise an error.
    # All of the failure errors extend from
    # {Aws::Waiters::Errors::WaiterFailed}.
    #
    #     begin
    #       client.wait_until(...)
    #     rescue Aws::Waiters::Errors::WaiterFailed
    #       # resource did not enter the desired state in time
    #     end
    #
    # ## Valid Waiters
    #
    # The following table lists the valid waiter names, the operations they call,
    # and the default `:delay` and `:max_attempts` values.
    #
    # | waiter_name       | params         | :delay   | :max_attempts |
    # | ----------------- | -------------- | -------- | ------------- |
    # | bucket_exists     | {#head_bucket} | 5        | 20            |
    # | bucket_not_exists | {#head_bucket} | 5        | 20            |
    # | object_exists     | {#head_object} | 5        | 20            |
    # | object_not_exists | {#head_object} | 5        | 20            |
    #
    # @raise [Errors::FailureStateError] Raised when the waiter terminates
    #   because the waiter has entered a state that it will not transition
    #   out of, preventing success.
    #
    # @raise [Errors::TooManyAttemptsError] Raised when the configured
    #   maximum number of attempts have been made, and the waiter is not
    #   yet successful.
    #
    # @raise [Errors::UnexpectedError] Raised when an error is encounted
    #   while polling for a resource that is not expected.
    #
    # @raise [Errors::NoSuchWaiterError] Raised when you request to wait
    #   for an unknown state.
    #
    # @return [Boolean] Returns `true` if the waiter was successful.
    # @param [Symbol] waiter_name
    # @param [Hash] params ({})
    # @param [Hash] options ({})
    # @option options [Integer] :max_attempts
    # @option options [Integer] :delay
    # @option options [Proc] :before_attempt
    # @option options [Proc] :before_wait
    def wait_until(waiter_name, params = {}, options = {})
      w = waiter(waiter_name, options)
      yield(w.waiter) if block_given? # deprecated
      w.wait(params)
    end

    # @api private
    # @deprecated
    def waiter_names
      waiters.keys
    end

    private

    # @param [Symbol] waiter_name
    # @param [Hash] options ({})
    def waiter(waiter_name, options = {})
      waiter_class = waiters[waiter_name]
      if waiter_class
        waiter_class.new(options.merge(client: self))
      else
        raise Aws::Waiters::Errors::NoSuchWaiterError.new(waiter_name, waiters.keys)
      end
    end

    def waiters
      {
        bucket_exists: Waiters::BucketExists,
        bucket_not_exists: Waiters::BucketNotExists,
        object_exists: Waiters::ObjectExists,
        object_not_exists: Waiters::ObjectNotExists
      }
    end

    class << self

      # @api private
      attr_reader :identifier

      # @api private
      def errors_module
        Errors
      end

    end
  end
end
