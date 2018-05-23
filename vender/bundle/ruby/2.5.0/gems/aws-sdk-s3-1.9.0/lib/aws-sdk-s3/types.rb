# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::S3
  module Types

    # Specifies the days since the initiation of an Incomplete Multipart
    # Upload that Lifecycle will wait before permanently removing all parts
    # of the upload.
    #
    # @note When making an API call, you may pass AbortIncompleteMultipartUpload
    #   data as a hash:
    #
    #       {
    #         days_after_initiation: 1,
    #       }
    #
    # @!attribute [rw] days_after_initiation
    #   Indicates the number of days that must pass since initiation for
    #   Lifecycle to abort an Incomplete Multipart Upload.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AbortIncompleteMultipartUpload AWS API Documentation
    #
    class AbortIncompleteMultipartUpload < Struct.new(
      :days_after_initiation)
      include Aws::Structure
    end

    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AbortMultipartUploadOutput AWS API Documentation
    #
    class AbortMultipartUploadOutput < Struct.new(
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AbortMultipartUploadRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         upload_id: "MultipartUploadId", # required
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] upload_id
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AbortMultipartUploadRequest AWS API Documentation
    #
    class AbortMultipartUploadRequest < Struct.new(
      :bucket,
      :key,
      :upload_id,
      :request_payer)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AccelerateConfiguration
    #   data as a hash:
    #
    #       {
    #         status: "Enabled", # accepts Enabled, Suspended
    #       }
    #
    # @!attribute [rw] status
    #   The accelerate configuration of the bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AccelerateConfiguration AWS API Documentation
    #
    class AccelerateConfiguration < Struct.new(
      :status)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AccessControlPolicy
    #   data as a hash:
    #
    #       {
    #         grants: [
    #           {
    #             grantee: {
    #               display_name: "DisplayName",
    #               email_address: "EmailAddress",
    #               id: "ID",
    #               type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #               uri: "URI",
    #             },
    #             permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #           },
    #         ],
    #         owner: {
    #           display_name: "DisplayName",
    #           id: "ID",
    #         },
    #       }
    #
    # @!attribute [rw] grants
    #   A list of grants.
    #   @return [Array<Types::Grant>]
    #
    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AccessControlPolicy AWS API Documentation
    #
    class AccessControlPolicy < Struct.new(
      :grants,
      :owner)
      include Aws::Structure
    end

    # Container for information regarding the access control for replicas.
    #
    # @note When making an API call, you may pass AccessControlTranslation
    #   data as a hash:
    #
    #       {
    #         owner: "Destination", # required, accepts Destination
    #       }
    #
    # @!attribute [rw] owner
    #   The override value for the owner of the replica object.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AccessControlTranslation AWS API Documentation
    #
    class AccessControlTranslation < Struct.new(
      :owner)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AnalyticsAndOperator
    #   data as a hash:
    #
    #       {
    #         prefix: "Prefix",
    #         tags: [
    #           {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] prefix
    #   The prefix to use when evaluating an AND predicate.
    #   @return [String]
    #
    # @!attribute [rw] tags
    #   The list of tags to use when evaluating an AND predicate.
    #   @return [Array<Types::Tag>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AnalyticsAndOperator AWS API Documentation
    #
    class AnalyticsAndOperator < Struct.new(
      :prefix,
      :tags)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AnalyticsConfiguration
    #   data as a hash:
    #
    #       {
    #         id: "AnalyticsId", # required
    #         filter: {
    #           prefix: "Prefix",
    #           tag: {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #           and: {
    #             prefix: "Prefix",
    #             tags: [
    #               {
    #                 key: "ObjectKey", # required
    #                 value: "Value", # required
    #               },
    #             ],
    #           },
    #         },
    #         storage_class_analysis: { # required
    #           data_export: {
    #             output_schema_version: "V_1", # required, accepts V_1
    #             destination: { # required
    #               s3_bucket_destination: { # required
    #                 format: "CSV", # required, accepts CSV
    #                 bucket_account_id: "AccountId",
    #                 bucket: "BucketName", # required
    #                 prefix: "Prefix",
    #               },
    #             },
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] id
    #   The identifier used to represent an analytics configuration.
    #   @return [String]
    #
    # @!attribute [rw] filter
    #   The filter used to describe a set of objects for analyses. A filter
    #   must have exactly one prefix, one tag, or one conjunction
    #   (AnalyticsAndOperator). If no filter is provided, all objects will
    #   be considered in any analysis.
    #   @return [Types::AnalyticsFilter]
    #
    # @!attribute [rw] storage_class_analysis
    #   If present, it indicates that data related to access patterns will
    #   be collected and made available to analyze the tradeoffs between
    #   different storage classes.
    #   @return [Types::StorageClassAnalysis]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AnalyticsConfiguration AWS API Documentation
    #
    class AnalyticsConfiguration < Struct.new(
      :id,
      :filter,
      :storage_class_analysis)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AnalyticsExportDestination
    #   data as a hash:
    #
    #       {
    #         s3_bucket_destination: { # required
    #           format: "CSV", # required, accepts CSV
    #           bucket_account_id: "AccountId",
    #           bucket: "BucketName", # required
    #           prefix: "Prefix",
    #         },
    #       }
    #
    # @!attribute [rw] s3_bucket_destination
    #   A destination signifying output to an S3 bucket.
    #   @return [Types::AnalyticsS3BucketDestination]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AnalyticsExportDestination AWS API Documentation
    #
    class AnalyticsExportDestination < Struct.new(
      :s3_bucket_destination)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AnalyticsFilter
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] prefix
    #   The prefix to use when evaluating an analytics filter.
    #   @return [String]
    #
    # @!attribute [rw] tag
    #   The tag to use when evaluating an analytics filter.
    #   @return [Types::Tag]
    #
    # @!attribute [rw] and
    #   A conjunction (logical AND) of predicates, which is used in
    #   evaluating an analytics filter. The operator must have at least two
    #   predicates.
    #   @return [Types::AnalyticsAndOperator]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AnalyticsFilter AWS API Documentation
    #
    class AnalyticsFilter < Struct.new(
      :prefix,
      :tag,
      :and)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AnalyticsS3BucketDestination
    #   data as a hash:
    #
    #       {
    #         format: "CSV", # required, accepts CSV
    #         bucket_account_id: "AccountId",
    #         bucket: "BucketName", # required
    #         prefix: "Prefix",
    #       }
    #
    # @!attribute [rw] format
    #   The file format used when exporting data to Amazon S3.
    #   @return [String]
    #
    # @!attribute [rw] bucket_account_id
    #   The account ID that owns the destination bucket. If no account ID is
    #   provided, the owner will not be validated prior to exporting data.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   The Amazon resource name (ARN) of the bucket to which data is
    #   exported.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   The prefix to use when exporting data. The exported data begins with
    #   this prefix.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/AnalyticsS3BucketDestination AWS API Documentation
    #
    class AnalyticsS3BucketDestination < Struct.new(
      :format,
      :bucket_account_id,
      :bucket,
      :prefix)
      include Aws::Structure
    end

    # @!attribute [rw] name
    #   The name of the bucket.
    #   @return [String]
    #
    # @!attribute [rw] creation_date
    #   Date the bucket was created.
    #   @return [Time]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Bucket AWS API Documentation
    #
    class Bucket < Struct.new(
      :name,
      :creation_date)
      include Aws::Structure
    end

    # @note When making an API call, you may pass BucketLifecycleConfiguration
    #   data as a hash:
    #
    #       {
    #         rules: [ # required
    #           {
    #             expiration: {
    #               date: Time.now,
    #               days: 1,
    #               expired_object_delete_marker: false,
    #             },
    #             id: "ID",
    #             prefix: "Prefix",
    #             filter: {
    #               prefix: "Prefix",
    #               tag: {
    #                 key: "ObjectKey", # required
    #                 value: "Value", # required
    #               },
    #               and: {
    #                 prefix: "Prefix",
    #                 tags: [
    #                   {
    #                     key: "ObjectKey", # required
    #                     value: "Value", # required
    #                   },
    #                 ],
    #               },
    #             },
    #             status: "Enabled", # required, accepts Enabled, Disabled
    #             transitions: [
    #               {
    #                 date: Time.now,
    #                 days: 1,
    #                 storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #               },
    #             ],
    #             noncurrent_version_transitions: [
    #               {
    #                 noncurrent_days: 1,
    #                 storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #               },
    #             ],
    #             noncurrent_version_expiration: {
    #               noncurrent_days: 1,
    #             },
    #             abort_incomplete_multipart_upload: {
    #               days_after_initiation: 1,
    #             },
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] rules
    #   @return [Array<Types::LifecycleRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/BucketLifecycleConfiguration AWS API Documentation
    #
    class BucketLifecycleConfiguration < Struct.new(
      :rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass BucketLoggingStatus
    #   data as a hash:
    #
    #       {
    #         logging_enabled: {
    #           target_bucket: "TargetBucket", # required
    #           target_grants: [
    #             {
    #               grantee: {
    #                 display_name: "DisplayName",
    #                 email_address: "EmailAddress",
    #                 id: "ID",
    #                 type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #                 uri: "URI",
    #               },
    #               permission: "FULL_CONTROL", # accepts FULL_CONTROL, READ, WRITE
    #             },
    #           ],
    #           target_prefix: "TargetPrefix", # required
    #         },
    #       }
    #
    # @!attribute [rw] logging_enabled
    #   Container for logging information. Presence of this element
    #   indicates that logging is enabled. Parameters TargetBucket and
    #   TargetPrefix are required in this case.
    #   @return [Types::LoggingEnabled]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/BucketLoggingStatus AWS API Documentation
    #
    class BucketLoggingStatus < Struct.new(
      :logging_enabled)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CORSConfiguration
    #   data as a hash:
    #
    #       {
    #         cors_rules: [ # required
    #           {
    #             allowed_headers: ["AllowedHeader"],
    #             allowed_methods: ["AllowedMethod"], # required
    #             allowed_origins: ["AllowedOrigin"], # required
    #             expose_headers: ["ExposeHeader"],
    #             max_age_seconds: 1,
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] cors_rules
    #   @return [Array<Types::CORSRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CORSConfiguration AWS API Documentation
    #
    class CORSConfiguration < Struct.new(
      :cors_rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CORSRule
    #   data as a hash:
    #
    #       {
    #         allowed_headers: ["AllowedHeader"],
    #         allowed_methods: ["AllowedMethod"], # required
    #         allowed_origins: ["AllowedOrigin"], # required
    #         expose_headers: ["ExposeHeader"],
    #         max_age_seconds: 1,
    #       }
    #
    # @!attribute [rw] allowed_headers
    #   Specifies which headers are allowed in a pre-flight OPTIONS request.
    #   @return [Array<String>]
    #
    # @!attribute [rw] allowed_methods
    #   Identifies HTTP methods that the domain/origin specified in the rule
    #   is allowed to execute.
    #   @return [Array<String>]
    #
    # @!attribute [rw] allowed_origins
    #   One or more origins you want customers to be able to access the
    #   bucket from.
    #   @return [Array<String>]
    #
    # @!attribute [rw] expose_headers
    #   One or more headers in the response that you want customers to be
    #   able to access from their applications (for example, from a
    #   JavaScript XMLHttpRequest object).
    #   @return [Array<String>]
    #
    # @!attribute [rw] max_age_seconds
    #   The time in seconds that your browser is to cache the preflight
    #   response for the specified resource.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CORSRule AWS API Documentation
    #
    class CORSRule < Struct.new(
      :allowed_headers,
      :allowed_methods,
      :allowed_origins,
      :expose_headers,
      :max_age_seconds)
      include Aws::Structure
    end

    # Describes how a CSV-formatted input object is formatted.
    #
    # @note When making an API call, you may pass CSVInput
    #   data as a hash:
    #
    #       {
    #         file_header_info: "USE", # accepts USE, IGNORE, NONE
    #         comments: "Comments",
    #         quote_escape_character: "QuoteEscapeCharacter",
    #         record_delimiter: "RecordDelimiter",
    #         field_delimiter: "FieldDelimiter",
    #         quote_character: "QuoteCharacter",
    #       }
    #
    # @!attribute [rw] file_header_info
    #   Describes the first line of input. Valid values: None, Ignore, Use.
    #   @return [String]
    #
    # @!attribute [rw] comments
    #   Single character used to indicate a row should be ignored when
    #   present at the start of a row.
    #   @return [String]
    #
    # @!attribute [rw] quote_escape_character
    #   Single character used for escaping the quote character inside an
    #   already escaped value.
    #   @return [String]
    #
    # @!attribute [rw] record_delimiter
    #   Value used to separate individual records.
    #   @return [String]
    #
    # @!attribute [rw] field_delimiter
    #   Value used to separate individual fields in a record.
    #   @return [String]
    #
    # @!attribute [rw] quote_character
    #   Value used for escaping where the field delimiter is part of the
    #   value.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CSVInput AWS API Documentation
    #
    class CSVInput < Struct.new(
      :file_header_info,
      :comments,
      :quote_escape_character,
      :record_delimiter,
      :field_delimiter,
      :quote_character)
      include Aws::Structure
    end

    # Describes how CSV-formatted results are formatted.
    #
    # @note When making an API call, you may pass CSVOutput
    #   data as a hash:
    #
    #       {
    #         quote_fields: "ALWAYS", # accepts ALWAYS, ASNEEDED
    #         quote_escape_character: "QuoteEscapeCharacter",
    #         record_delimiter: "RecordDelimiter",
    #         field_delimiter: "FieldDelimiter",
    #         quote_character: "QuoteCharacter",
    #       }
    #
    # @!attribute [rw] quote_fields
    #   Indicates whether or not all output fields should be quoted.
    #   @return [String]
    #
    # @!attribute [rw] quote_escape_character
    #   Single character used for escaping the quote character inside an
    #   already escaped value.
    #   @return [String]
    #
    # @!attribute [rw] record_delimiter
    #   Value used to separate individual records.
    #   @return [String]
    #
    # @!attribute [rw] field_delimiter
    #   Value used to separate individual fields in a record.
    #   @return [String]
    #
    # @!attribute [rw] quote_character
    #   Value used for escaping where the field delimiter is part of the
    #   value.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CSVOutput AWS API Documentation
    #
    class CSVOutput < Struct.new(
      :quote_fields,
      :quote_escape_character,
      :record_delimiter,
      :field_delimiter,
      :quote_character)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CloudFunctionConfiguration
    #   data as a hash:
    #
    #       {
    #         id: "NotificationId",
    #         event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         cloud_function: "CloudFunction",
    #         invocation_role: "CloudFunctionInvocationRole",
    #       }
    #
    # @!attribute [rw] id
    #   Optional unique identifier for configurations in a notification
    #   configuration. If you don't provide one, Amazon S3 will assign an
    #   ID.
    #   @return [String]
    #
    # @!attribute [rw] event
    #   Bucket event for which to send notifications.
    #   @return [String]
    #
    # @!attribute [rw] events
    #   @return [Array<String>]
    #
    # @!attribute [rw] cloud_function
    #   @return [String]
    #
    # @!attribute [rw] invocation_role
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CloudFunctionConfiguration AWS API Documentation
    #
    class CloudFunctionConfiguration < Struct.new(
      :id,
      :event,
      :events,
      :cloud_function,
      :invocation_role)
      include Aws::Structure
    end

    # @!attribute [rw] prefix
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CommonPrefix AWS API Documentation
    #
    class CommonPrefix < Struct.new(
      :prefix)
      include Aws::Structure
    end

    # @!attribute [rw] location
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] expiration
    #   If the object expiration is configured, this will contain the
    #   expiration date (expiry-date) and rule ID (rule-id). The value of
    #   rule-id is URL encoded.
    #   @return [String]
    #
    # @!attribute [rw] etag
    #   Entity tag of the object.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   Version of the object.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CompleteMultipartUploadOutput AWS API Documentation
    #
    class CompleteMultipartUploadOutput < Struct.new(
      :location,
      :bucket,
      :key,
      :expiration,
      :etag,
      :server_side_encryption,
      :version_id,
      :ssekms_key_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CompleteMultipartUploadRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         multipart_upload: {
    #           parts: [
    #             {
    #               etag: "ETag",
    #               part_number: 1,
    #             },
    #           ],
    #         },
    #         upload_id: "MultipartUploadId", # required
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] multipart_upload
    #   @return [Types::CompletedMultipartUpload]
    #
    # @!attribute [rw] upload_id
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CompleteMultipartUploadRequest AWS API Documentation
    #
    class CompleteMultipartUploadRequest < Struct.new(
      :bucket,
      :key,
      :multipart_upload,
      :upload_id,
      :request_payer)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CompletedMultipartUpload
    #   data as a hash:
    #
    #       {
    #         parts: [
    #           {
    #             etag: "ETag",
    #             part_number: 1,
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] parts
    #   @return [Array<Types::CompletedPart>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CompletedMultipartUpload AWS API Documentation
    #
    class CompletedMultipartUpload < Struct.new(
      :parts)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CompletedPart
    #   data as a hash:
    #
    #       {
    #         etag: "ETag",
    #         part_number: 1,
    #       }
    #
    # @!attribute [rw] etag
    #   Entity tag returned when the part was uploaded.
    #   @return [String]
    #
    # @!attribute [rw] part_number
    #   Part number that identifies the part. This is a positive integer
    #   between 1 and 10,000.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CompletedPart AWS API Documentation
    #
    class CompletedPart < Struct.new(
      :etag,
      :part_number)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Condition
    #   data as a hash:
    #
    #       {
    #         http_error_code_returned_equals: "HttpErrorCodeReturnedEquals",
    #         key_prefix_equals: "KeyPrefixEquals",
    #       }
    #
    # @!attribute [rw] http_error_code_returned_equals
    #   The HTTP error code when the redirect is applied. In the event of an
    #   error, if the error code equals this value, then the specified
    #   redirect is applied. Required when parent element Condition is
    #   specified and sibling KeyPrefixEquals is not specified. If both are
    #   specified, then both must be true for the redirect to be applied.
    #   @return [String]
    #
    # @!attribute [rw] key_prefix_equals
    #   The object key name prefix when the redirect is applied. For
    #   example, to redirect requests for ExamplePage.html, the key prefix
    #   will be ExamplePage.html. To redirect request for all pages with the
    #   prefix docs/, the key prefix will be /docs, which identifies all
    #   objects in the docs/ folder. Required when the parent element
    #   Condition is specified and sibling HttpErrorCodeReturnedEquals is
    #   not specified. If both conditions are specified, both must be true
    #   for the redirect to be applied.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Condition AWS API Documentation
    #
    class Condition < Struct.new(
      :http_error_code_returned_equals,
      :key_prefix_equals)
      include Aws::Structure
    end

    # @!attribute [rw] copy_object_result
    #   @return [Types::CopyObjectResult]
    #
    # @!attribute [rw] expiration
    #   If the object expiration is configured, the response includes this
    #   header.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_version_id
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   Version ID of the newly created copy.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CopyObjectOutput AWS API Documentation
    #
    class CopyObjectOutput < Struct.new(
      :copy_object_result,
      :expiration,
      :copy_source_version_id,
      :version_id,
      :server_side_encryption,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CopyObjectRequest
    #   data as a hash:
    #
    #       {
    #         acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #         bucket: "BucketName", # required
    #         cache_control: "CacheControl",
    #         content_disposition: "ContentDisposition",
    #         content_encoding: "ContentEncoding",
    #         content_language: "ContentLanguage",
    #         content_type: "ContentType",
    #         copy_source: "CopySource", # required
    #         copy_source_if_match: "CopySourceIfMatch",
    #         copy_source_if_modified_since: Time.now,
    #         copy_source_if_none_match: "CopySourceIfNoneMatch",
    #         copy_source_if_unmodified_since: Time.now,
    #         expires: Time.now,
    #         grant_full_control: "GrantFullControl",
    #         grant_read: "GrantRead",
    #         grant_read_acp: "GrantReadACP",
    #         grant_write_acp: "GrantWriteACP",
    #         key: "ObjectKey", # required
    #         metadata: {
    #           "MetadataKey" => "MetadataValue",
    #         },
    #         metadata_directive: "COPY", # accepts COPY, REPLACE
    #         tagging_directive: "COPY", # accepts COPY, REPLACE
    #         server_side_encryption: "AES256", # accepts AES256, aws:kms
    #         storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #         website_redirect_location: "WebsiteRedirectLocation",
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         ssekms_key_id: "SSEKMSKeyId",
    #         copy_source_sse_customer_algorithm: "CopySourceSSECustomerAlgorithm",
    #         copy_source_sse_customer_key: "CopySourceSSECustomerKey",
    #         copy_source_sse_customer_key_md5: "CopySourceSSECustomerKeyMD5",
    #         request_payer: "requester", # accepts requester
    #         tagging: "TaggingHeader",
    #       }
    #
    # @!attribute [rw] acl
    #   The canned ACL to apply to the object.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] cache_control
    #   Specifies caching behavior along the request/reply chain.
    #   @return [String]
    #
    # @!attribute [rw] content_disposition
    #   Specifies presentational information for the object.
    #   @return [String]
    #
    # @!attribute [rw] content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the
    #   media-type referenced by the Content-Type header field.
    #   @return [String]
    #
    # @!attribute [rw] content_language
    #   The language the content is in.
    #   @return [String]
    #
    # @!attribute [rw] content_type
    #   A standard MIME type describing the format of the object data.
    #   @return [String]
    #
    # @!attribute [rw] copy_source
    #   The name of the source bucket and key name of the source object,
    #   separated by a slash (/). Must be URL-encoded.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_if_match
    #   Copies the object if its entity tag (ETag) matches the specified
    #   tag.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_if_modified_since
    #   Copies the object if it has been modified since the specified time.
    #   @return [Time]
    #
    # @!attribute [rw] copy_source_if_none_match
    #   Copies the object if its entity tag (ETag) is different than the
    #   specified ETag.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_if_unmodified_since
    #   Copies the object if it hasn't been modified since the specified
    #   time.
    #   @return [Time]
    #
    # @!attribute [rw] expires
    #   The date and time at which the object is no longer cacheable.
    #   @return [Time]
    #
    # @!attribute [rw] grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    #   @return [String]
    #
    # @!attribute [rw] grant_read
    #   Allows grantee to read the object data and its metadata.
    #   @return [String]
    #
    # @!attribute [rw] grant_read_acp
    #   Allows grantee to read the object ACL.
    #   @return [String]
    #
    # @!attribute [rw] grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] metadata
    #   A map of metadata to store with the object in S3.
    #   @return [Hash<String,String>]
    #
    # @!attribute [rw] metadata_directive
    #   Specifies whether the metadata is copied from the source object or
    #   replaced with metadata provided in the request.
    #   @return [String]
    #
    # @!attribute [rw] tagging_directive
    #   Specifies whether the object tag-set are copied from the source
    #   object or replaced with tag-set provided in the request.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    #   @return [String]
    #
    # @!attribute [rw] website_redirect_location
    #   If the bucket is configured as a website, redirects requests for
    #   this object to another object in the same bucket or to an external
    #   URL. Amazon S3 stores the value of this header in the object
    #   metadata.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET
    #   and PUT requests for an object protected by AWS KMS will fail if not
    #   made via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    #   @return [String]
    #
    # @!attribute [rw] copy_source_sse_customer_algorithm
    #   Specifies the algorithm to use when decrypting the source object
    #   (e.g., AES256).
    #   @return [String]
    #
    # @!attribute [rw] copy_source_sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   to decrypt the source object. The encryption key provided in this
    #   header must be one that was used when the source object was created.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @!attribute [rw] tagging
    #   The tag-set for the object destination object this value must be
    #   used in conjunction with the TaggingDirective. The tag-set must be
    #   encoded as URL Query parameters
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CopyObjectRequest AWS API Documentation
    #
    class CopyObjectRequest < Struct.new(
      :acl,
      :bucket,
      :cache_control,
      :content_disposition,
      :content_encoding,
      :content_language,
      :content_type,
      :copy_source,
      :copy_source_if_match,
      :copy_source_if_modified_since,
      :copy_source_if_none_match,
      :copy_source_if_unmodified_since,
      :expires,
      :grant_full_control,
      :grant_read,
      :grant_read_acp,
      :grant_write_acp,
      :key,
      :metadata,
      :metadata_directive,
      :tagging_directive,
      :server_side_encryption,
      :storage_class,
      :website_redirect_location,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :copy_source_sse_customer_algorithm,
      :copy_source_sse_customer_key,
      :copy_source_sse_customer_key_md5,
      :request_payer,
      :tagging)
      include Aws::Structure
    end

    # @!attribute [rw] etag
    #   @return [String]
    #
    # @!attribute [rw] last_modified
    #   @return [Time]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CopyObjectResult AWS API Documentation
    #
    class CopyObjectResult < Struct.new(
      :etag,
      :last_modified)
      include Aws::Structure
    end

    # @!attribute [rw] etag
    #   Entity tag of the object.
    #   @return [String]
    #
    # @!attribute [rw] last_modified
    #   Date and time at which the object was uploaded.
    #   @return [Time]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CopyPartResult AWS API Documentation
    #
    class CopyPartResult < Struct.new(
      :etag,
      :last_modified)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CreateBucketConfiguration
    #   data as a hash:
    #
    #       {
    #         location_constraint: "EU", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
    #       }
    #
    # @!attribute [rw] location_constraint
    #   Specifies the region where the bucket will be created. If you don't
    #   specify a region, the bucket will be created in US Standard.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateBucketConfiguration AWS API Documentation
    #
    class CreateBucketConfiguration < Struct.new(
      :location_constraint)
      include Aws::Structure
    end

    # @!attribute [rw] location
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateBucketOutput AWS API Documentation
    #
    class CreateBucketOutput < Struct.new(
      :location)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CreateBucketRequest
    #   data as a hash:
    #
    #       {
    #         acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #         bucket: "BucketName", # required
    #         create_bucket_configuration: {
    #           location_constraint: "EU", # accepts EU, eu-west-1, us-west-1, us-west-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1, cn-north-1, eu-central-1
    #         },
    #         grant_full_control: "GrantFullControl",
    #         grant_read: "GrantRead",
    #         grant_read_acp: "GrantReadACP",
    #         grant_write: "GrantWrite",
    #         grant_write_acp: "GrantWriteACP",
    #       }
    #
    # @!attribute [rw] acl
    #   The canned ACL to apply to the bucket.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] create_bucket_configuration
    #   @return [Types::CreateBucketConfiguration]
    #
    # @!attribute [rw] grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions
    #   on the bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_read
    #   Allows grantee to list the objects in the bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_read_acp
    #   Allows grantee to read the bucket ACL.
    #   @return [String]
    #
    # @!attribute [rw] grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateBucketRequest AWS API Documentation
    #
    class CreateBucketRequest < Struct.new(
      :acl,
      :bucket,
      :create_bucket_configuration,
      :grant_full_control,
      :grant_read,
      :grant_read_acp,
      :grant_write,
      :grant_write_acp)
      include Aws::Structure
    end

    # @!attribute [rw] abort_date
    #   Date when multipart upload will become eligible for abort operation
    #   by lifecycle.
    #   @return [Time]
    #
    # @!attribute [rw] abort_rule_id
    #   Id of the lifecycle rule that makes a multipart upload eligible for
    #   abort operation.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   Name of the bucket to which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   Object key for which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] upload_id
    #   ID for the initiated multipart upload.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateMultipartUploadOutput AWS API Documentation
    #
    class CreateMultipartUploadOutput < Struct.new(
      :abort_date,
      :abort_rule_id,
      :bucket,
      :key,
      :upload_id,
      :server_side_encryption,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass CreateMultipartUploadRequest
    #   data as a hash:
    #
    #       {
    #         acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #         bucket: "BucketName", # required
    #         cache_control: "CacheControl",
    #         content_disposition: "ContentDisposition",
    #         content_encoding: "ContentEncoding",
    #         content_language: "ContentLanguage",
    #         content_type: "ContentType",
    #         expires: Time.now,
    #         grant_full_control: "GrantFullControl",
    #         grant_read: "GrantRead",
    #         grant_read_acp: "GrantReadACP",
    #         grant_write_acp: "GrantWriteACP",
    #         key: "ObjectKey", # required
    #         metadata: {
    #           "MetadataKey" => "MetadataValue",
    #         },
    #         server_side_encryption: "AES256", # accepts AES256, aws:kms
    #         storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #         website_redirect_location: "WebsiteRedirectLocation",
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         ssekms_key_id: "SSEKMSKeyId",
    #         request_payer: "requester", # accepts requester
    #         tagging: "TaggingHeader",
    #       }
    #
    # @!attribute [rw] acl
    #   The canned ACL to apply to the object.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] cache_control
    #   Specifies caching behavior along the request/reply chain.
    #   @return [String]
    #
    # @!attribute [rw] content_disposition
    #   Specifies presentational information for the object.
    #   @return [String]
    #
    # @!attribute [rw] content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the
    #   media-type referenced by the Content-Type header field.
    #   @return [String]
    #
    # @!attribute [rw] content_language
    #   The language the content is in.
    #   @return [String]
    #
    # @!attribute [rw] content_type
    #   A standard MIME type describing the format of the object data.
    #   @return [String]
    #
    # @!attribute [rw] expires
    #   The date and time at which the object is no longer cacheable.
    #   @return [Time]
    #
    # @!attribute [rw] grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    #   @return [String]
    #
    # @!attribute [rw] grant_read
    #   Allows grantee to read the object data and its metadata.
    #   @return [String]
    #
    # @!attribute [rw] grant_read_acp
    #   Allows grantee to read the object ACL.
    #   @return [String]
    #
    # @!attribute [rw] grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] metadata
    #   A map of metadata to store with the object in S3.
    #   @return [Hash<String,String>]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    #   @return [String]
    #
    # @!attribute [rw] website_redirect_location
    #   If the bucket is configured as a website, redirects requests for
    #   this object to another object in the same bucket or to an external
    #   URL. Amazon S3 stores the value of this header in the object
    #   metadata.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET
    #   and PUT requests for an object protected by AWS KMS will fail if not
    #   made via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @!attribute [rw] tagging
    #   The tag-set for the object. The tag-set must be encoded as URL Query
    #   parameters
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/CreateMultipartUploadRequest AWS API Documentation
    #
    class CreateMultipartUploadRequest < Struct.new(
      :acl,
      :bucket,
      :cache_control,
      :content_disposition,
      :content_encoding,
      :content_language,
      :content_type,
      :expires,
      :grant_full_control,
      :grant_read,
      :grant_read_acp,
      :grant_write_acp,
      :key,
      :metadata,
      :server_side_encryption,
      :storage_class,
      :website_redirect_location,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_payer,
      :tagging)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Delete
    #   data as a hash:
    #
    #       {
    #         objects: [ # required
    #           {
    #             key: "ObjectKey", # required
    #             version_id: "ObjectVersionId",
    #           },
    #         ],
    #         quiet: false,
    #       }
    #
    # @!attribute [rw] objects
    #   @return [Array<Types::ObjectIdentifier>]
    #
    # @!attribute [rw] quiet
    #   Element to enable quiet mode for the request. When you add this
    #   element, you must set its value to true.
    #   @return [Boolean]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Delete AWS API Documentation
    #
    class Delete < Struct.new(
      :objects,
      :quiet)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketAnalyticsConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "AnalyticsId", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket from which an analytics configuration is
    #   deleted.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The identifier used to represent an analytics configuration.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketAnalyticsConfigurationRequest AWS API Documentation
    #
    class DeleteBucketAnalyticsConfigurationRequest < Struct.new(
      :bucket,
      :id)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketCorsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketCorsRequest AWS API Documentation
    #
    class DeleteBucketCorsRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketEncryptionRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the server-side encryption
    #   configuration to delete.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketEncryptionRequest AWS API Documentation
    #
    class DeleteBucketEncryptionRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketInventoryConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "InventoryId", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the inventory configuration to
    #   delete.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The ID used to identify the inventory configuration.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketInventoryConfigurationRequest AWS API Documentation
    #
    class DeleteBucketInventoryConfigurationRequest < Struct.new(
      :bucket,
      :id)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketLifecycleRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketLifecycleRequest AWS API Documentation
    #
    class DeleteBucketLifecycleRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketMetricsConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "MetricsId", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the metrics configuration to
    #   delete.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The ID used to identify the metrics configuration.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketMetricsConfigurationRequest AWS API Documentation
    #
    class DeleteBucketMetricsConfigurationRequest < Struct.new(
      :bucket,
      :id)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketPolicyRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketPolicyRequest AWS API Documentation
    #
    class DeleteBucketPolicyRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketReplicationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketReplicationRequest AWS API Documentation
    #
    class DeleteBucketReplicationRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketRequest AWS API Documentation
    #
    class DeleteBucketRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketTaggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketTaggingRequest AWS API Documentation
    #
    class DeleteBucketTaggingRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteBucketWebsiteRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteBucketWebsiteRequest AWS API Documentation
    #
    class DeleteBucketWebsiteRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @!attribute [rw] key
    #   The object key.
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   Version ID of an object.
    #   @return [String]
    #
    # @!attribute [rw] is_latest
    #   Specifies whether the object is (true) or is not (false) the latest
    #   version of an object.
    #   @return [Boolean]
    #
    # @!attribute [rw] last_modified
    #   Date and time the object was last modified.
    #   @return [Time]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteMarkerEntry AWS API Documentation
    #
    class DeleteMarkerEntry < Struct.new(
      :owner,
      :key,
      :version_id,
      :is_latest,
      :last_modified)
      include Aws::Structure
    end

    # @!attribute [rw] delete_marker
    #   Specifies whether the versioned object that was permanently deleted
    #   was (true) or was not (false) a delete marker.
    #   @return [Boolean]
    #
    # @!attribute [rw] version_id
    #   Returns the version ID of the delete marker created as a result of
    #   the DELETE operation.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectOutput AWS API Documentation
    #
    class DeleteObjectOutput < Struct.new(
      :delete_marker,
      :version_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteObjectRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         mfa: "MFA",
    #         version_id: "ObjectVersionId",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication
    #   device.
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   VersionId used to reference a specific version of the object.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectRequest AWS API Documentation
    #
    class DeleteObjectRequest < Struct.new(
      :bucket,
      :key,
      :mfa,
      :version_id,
      :request_payer)
      include Aws::Structure
    end

    # @!attribute [rw] version_id
    #   The versionId of the object the tag-set was removed from.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectTaggingOutput AWS API Documentation
    #
    class DeleteObjectTaggingOutput < Struct.new(
      :version_id)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteObjectTaggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         version_id: "ObjectVersionId",
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   The versionId of the object that the tag-set will be removed from.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectTaggingRequest AWS API Documentation
    #
    class DeleteObjectTaggingRequest < Struct.new(
      :bucket,
      :key,
      :version_id)
      include Aws::Structure
    end

    # @!attribute [rw] deleted
    #   @return [Array<Types::DeletedObject>]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @!attribute [rw] errors
    #   @return [Array<Types::Error>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectsOutput AWS API Documentation
    #
    class DeleteObjectsOutput < Struct.new(
      :deleted,
      :request_charged,
      :errors)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DeleteObjectsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         delete: { # required
    #           objects: [ # required
    #             {
    #               key: "ObjectKey", # required
    #               version_id: "ObjectVersionId",
    #             },
    #           ],
    #           quiet: false,
    #         },
    #         mfa: "MFA",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] delete
    #   @return [Types::Delete]
    #
    # @!attribute [rw] mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication
    #   device.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeleteObjectsRequest AWS API Documentation
    #
    class DeleteObjectsRequest < Struct.new(
      :bucket,
      :delete,
      :mfa,
      :request_payer)
      include Aws::Structure
    end

    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @!attribute [rw] delete_marker
    #   @return [Boolean]
    #
    # @!attribute [rw] delete_marker_version_id
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/DeletedObject AWS API Documentation
    #
    class DeletedObject < Struct.new(
      :key,
      :version_id,
      :delete_marker,
      :delete_marker_version_id)
      include Aws::Structure
    end

    # Container for replication destination information.
    #
    # @note When making an API call, you may pass Destination
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         account: "AccountId",
    #         storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #         access_control_translation: {
    #           owner: "Destination", # required, accepts Destination
    #         },
    #         encryption_configuration: {
    #           replica_kms_key_id: "ReplicaKmsKeyID",
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   Amazon resource name (ARN) of the bucket where you want Amazon S3 to
    #   store replicas of the object identified by the rule.
    #   @return [String]
    #
    # @!attribute [rw] account
    #   Account ID of the destination bucket. Currently this is only being
    #   verified if Access Control Translation is enabled
    #   @return [String]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @!attribute [rw] access_control_translation
    #   Container for information regarding the access control for replicas.
    #   @return [Types::AccessControlTranslation]
    #
    # @!attribute [rw] encryption_configuration
    #   Container for information regarding encryption based configuration
    #   for replicas.
    #   @return [Types::EncryptionConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Destination AWS API Documentation
    #
    class Destination < Struct.new(
      :bucket,
      :account,
      :storage_class,
      :access_control_translation,
      :encryption_configuration)
      include Aws::Structure
    end

    # Describes the server-side encryption that will be applied to the
    # restore results.
    #
    # @note When making an API call, you may pass Encryption
    #   data as a hash:
    #
    #       {
    #         encryption_type: "AES256", # required, accepts AES256, aws:kms
    #         kms_key_id: "SSEKMSKeyId",
    #         kms_context: "KMSContext",
    #       }
    #
    # @!attribute [rw] encryption_type
    #   The server-side encryption algorithm used when storing job results
    #   in Amazon S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] kms_key_id
    #   If the encryption type is aws:kms, this optional value specifies the
    #   AWS KMS key ID to use for encryption of job results.
    #   @return [String]
    #
    # @!attribute [rw] kms_context
    #   If the encryption type is aws:kms, this optional value can be used
    #   to specify the encryption context for the restore results.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Encryption AWS API Documentation
    #
    class Encryption < Struct.new(
      :encryption_type,
      :kms_key_id,
      :kms_context)
      include Aws::Structure
    end

    # Container for information regarding encryption based configuration for
    # replicas.
    #
    # @note When making an API call, you may pass EncryptionConfiguration
    #   data as a hash:
    #
    #       {
    #         replica_kms_key_id: "ReplicaKmsKeyID",
    #       }
    #
    # @!attribute [rw] replica_kms_key_id
    #   The id of the KMS key used to encrypt the replica object.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/EncryptionConfiguration AWS API Documentation
    #
    class EncryptionConfiguration < Struct.new(
      :replica_kms_key_id)
      include Aws::Structure
    end

    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @!attribute [rw] code
    #   @return [String]
    #
    # @!attribute [rw] message
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Error AWS API Documentation
    #
    class Error < Struct.new(
      :key,
      :version_id,
      :code,
      :message)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ErrorDocument
    #   data as a hash:
    #
    #       {
    #         key: "ObjectKey", # required
    #       }
    #
    # @!attribute [rw] key
    #   The object key name to use when a 4XX class error occurs.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ErrorDocument AWS API Documentation
    #
    class ErrorDocument < Struct.new(
      :key)
      include Aws::Structure
    end

    # Container for key value pair that defines the criteria for the filter
    # rule.
    #
    # @note When making an API call, you may pass FilterRule
    #   data as a hash:
    #
    #       {
    #         name: "prefix", # accepts prefix, suffix
    #         value: "FilterRuleValue",
    #       }
    #
    # @!attribute [rw] name
    #   Object key name prefix or suffix identifying one or more objects to
    #   which the filtering rule applies. Maximum prefix length can be up to
    #   1,024 characters. Overlapping prefixes and suffixes are not
    #   supported. For more information, go to [Configuring Event
    #   Notifications][1] in the Amazon Simple Storage Service Developer
    #   Guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
    #   @return [String]
    #
    # @!attribute [rw] value
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/FilterRule AWS API Documentation
    #
    class FilterRule < Struct.new(
      :name,
      :value)
      include Aws::Structure
    end

    # @!attribute [rw] status
    #   The accelerate configuration of the bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAccelerateConfigurationOutput AWS API Documentation
    #
    class GetBucketAccelerateConfigurationOutput < Struct.new(
      :status)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketAccelerateConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   Name of the bucket for which the accelerate configuration is
    #   retrieved.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAccelerateConfigurationRequest AWS API Documentation
    #
    class GetBucketAccelerateConfigurationRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @!attribute [rw] grants
    #   A list of grants.
    #   @return [Array<Types::Grant>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAclOutput AWS API Documentation
    #
    class GetBucketAclOutput < Struct.new(
      :owner,
      :grants)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketAclRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAclRequest AWS API Documentation
    #
    class GetBucketAclRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] analytics_configuration
    #   The configuration and any analyses for the analytics filter.
    #   @return [Types::AnalyticsConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAnalyticsConfigurationOutput AWS API Documentation
    #
    class GetBucketAnalyticsConfigurationOutput < Struct.new(
      :analytics_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketAnalyticsConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "AnalyticsId", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket from which an analytics configuration is
    #   retrieved.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The identifier used to represent an analytics configuration.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketAnalyticsConfigurationRequest AWS API Documentation
    #
    class GetBucketAnalyticsConfigurationRequest < Struct.new(
      :bucket,
      :id)
      include Aws::Structure
    end

    # @!attribute [rw] cors_rules
    #   @return [Array<Types::CORSRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketCorsOutput AWS API Documentation
    #
    class GetBucketCorsOutput < Struct.new(
      :cors_rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketCorsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketCorsRequest AWS API Documentation
    #
    class GetBucketCorsRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] server_side_encryption_configuration
    #   Container for server-side encryption configuration rules. Currently
    #   S3 supports one rule only.
    #   @return [Types::ServerSideEncryptionConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketEncryptionOutput AWS API Documentation
    #
    class GetBucketEncryptionOutput < Struct.new(
      :server_side_encryption_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketEncryptionRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket from which the server-side encryption
    #   configuration is retrieved.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketEncryptionRequest AWS API Documentation
    #
    class GetBucketEncryptionRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] inventory_configuration
    #   Specifies the inventory configuration.
    #   @return [Types::InventoryConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketInventoryConfigurationOutput AWS API Documentation
    #
    class GetBucketInventoryConfigurationOutput < Struct.new(
      :inventory_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketInventoryConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "InventoryId", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the inventory configuration to
    #   retrieve.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The ID used to identify the inventory configuration.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketInventoryConfigurationRequest AWS API Documentation
    #
    class GetBucketInventoryConfigurationRequest < Struct.new(
      :bucket,
      :id)
      include Aws::Structure
    end

    # @!attribute [rw] rules
    #   @return [Array<Types::LifecycleRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLifecycleConfigurationOutput AWS API Documentation
    #
    class GetBucketLifecycleConfigurationOutput < Struct.new(
      :rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketLifecycleConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLifecycleConfigurationRequest AWS API Documentation
    #
    class GetBucketLifecycleConfigurationRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] rules
    #   @return [Array<Types::Rule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLifecycleOutput AWS API Documentation
    #
    class GetBucketLifecycleOutput < Struct.new(
      :rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketLifecycleRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLifecycleRequest AWS API Documentation
    #
    class GetBucketLifecycleRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] location_constraint
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLocationOutput AWS API Documentation
    #
    class GetBucketLocationOutput < Struct.new(
      :location_constraint)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketLocationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLocationRequest AWS API Documentation
    #
    class GetBucketLocationRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] logging_enabled
    #   Container for logging information. Presence of this element
    #   indicates that logging is enabled. Parameters TargetBucket and
    #   TargetPrefix are required in this case.
    #   @return [Types::LoggingEnabled]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLoggingOutput AWS API Documentation
    #
    class GetBucketLoggingOutput < Struct.new(
      :logging_enabled)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketLoggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketLoggingRequest AWS API Documentation
    #
    class GetBucketLoggingRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] metrics_configuration
    #   Specifies the metrics configuration.
    #   @return [Types::MetricsConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketMetricsConfigurationOutput AWS API Documentation
    #
    class GetBucketMetricsConfigurationOutput < Struct.new(
      :metrics_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketMetricsConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "MetricsId", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the metrics configuration to
    #   retrieve.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The ID used to identify the metrics configuration.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketMetricsConfigurationRequest AWS API Documentation
    #
    class GetBucketMetricsConfigurationRequest < Struct.new(
      :bucket,
      :id)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketNotificationConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   Name of the bucket to get the notification configuration for.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketNotificationConfigurationRequest AWS API Documentation
    #
    class GetBucketNotificationConfigurationRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] policy
    #   The bucket policy as a JSON document.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketPolicyOutput AWS API Documentation
    #
    class GetBucketPolicyOutput < Struct.new(
      :policy)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketPolicyRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketPolicyRequest AWS API Documentation
    #
    class GetBucketPolicyRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] replication_configuration
    #   Container for replication rules. You can add as many as 1,000 rules.
    #   Total replication configuration size can be up to 2 MB.
    #   @return [Types::ReplicationConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketReplicationOutput AWS API Documentation
    #
    class GetBucketReplicationOutput < Struct.new(
      :replication_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketReplicationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketReplicationRequest AWS API Documentation
    #
    class GetBucketReplicationRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] payer
    #   Specifies who pays for the download and request fees.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketRequestPaymentOutput AWS API Documentation
    #
    class GetBucketRequestPaymentOutput < Struct.new(
      :payer)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketRequestPaymentRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketRequestPaymentRequest AWS API Documentation
    #
    class GetBucketRequestPaymentRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] tag_set
    #   @return [Array<Types::Tag>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketTaggingOutput AWS API Documentation
    #
    class GetBucketTaggingOutput < Struct.new(
      :tag_set)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketTaggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketTaggingRequest AWS API Documentation
    #
    class GetBucketTaggingRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] status
    #   The versioning state of the bucket.
    #   @return [String]
    #
    # @!attribute [rw] mfa_delete
    #   Specifies whether MFA delete is enabled in the bucket versioning
    #   configuration. This element is only returned if the bucket has been
    #   configured with MFA delete. If the bucket has never been so
    #   configured, this element is not returned.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketVersioningOutput AWS API Documentation
    #
    class GetBucketVersioningOutput < Struct.new(
      :status,
      :mfa_delete)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketVersioningRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketVersioningRequest AWS API Documentation
    #
    class GetBucketVersioningRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] redirect_all_requests_to
    #   @return [Types::RedirectAllRequestsTo]
    #
    # @!attribute [rw] index_document
    #   @return [Types::IndexDocument]
    #
    # @!attribute [rw] error_document
    #   @return [Types::ErrorDocument]
    #
    # @!attribute [rw] routing_rules
    #   @return [Array<Types::RoutingRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketWebsiteOutput AWS API Documentation
    #
    class GetBucketWebsiteOutput < Struct.new(
      :redirect_all_requests_to,
      :index_document,
      :error_document,
      :routing_rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetBucketWebsiteRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetBucketWebsiteRequest AWS API Documentation
    #
    class GetBucketWebsiteRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @!attribute [rw] grants
    #   A list of grants.
    #   @return [Array<Types::Grant>]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectAclOutput AWS API Documentation
    #
    class GetObjectAclOutput < Struct.new(
      :owner,
      :grants,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetObjectAclRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         version_id: "ObjectVersionId",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   VersionId used to reference a specific version of the object.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectAclRequest AWS API Documentation
    #
    class GetObjectAclRequest < Struct.new(
      :bucket,
      :key,
      :version_id,
      :request_payer)
      include Aws::Structure
    end

    # @!attribute [rw] body
    #   Object data.
    #   @return [IO]
    #
    # @!attribute [rw] delete_marker
    #   Specifies whether the object retrieved was (true) or was not (false)
    #   a Delete Marker. If false, this response header does not appear in
    #   the response.
    #   @return [Boolean]
    #
    # @!attribute [rw] accept_ranges
    #   @return [String]
    #
    # @!attribute [rw] expiration
    #   If the object expiration is configured (see PUT Bucket lifecycle),
    #   the response includes this header. It includes the expiry-date and
    #   rule-id key value pairs providing object expiration information. The
    #   value of the rule-id is URL encoded.
    #   @return [String]
    #
    # @!attribute [rw] restore
    #   Provides information about object restoration operation and
    #   expiration time of the restored object copy.
    #   @return [String]
    #
    # @!attribute [rw] last_modified
    #   Last modified date of the object
    #   @return [Time]
    #
    # @!attribute [rw] content_length
    #   Size of the body in bytes.
    #   @return [Integer]
    #
    # @!attribute [rw] etag
    #   An ETag is an opaque identifier assigned by a web server to a
    #   specific version of a resource found at a URL
    #   @return [String]
    #
    # @!attribute [rw] missing_meta
    #   This is set to the number of metadata entries not returned in
    #   x-amz-meta headers. This can happen if you create metadata using an
    #   API like SOAP that supports more flexible metadata than the REST
    #   API. For example, using SOAP, you can create metadata whose values
    #   are not legal HTTP headers.
    #   @return [Integer]
    #
    # @!attribute [rw] version_id
    #   Version of the object.
    #   @return [String]
    #
    # @!attribute [rw] cache_control
    #   Specifies caching behavior along the request/reply chain.
    #   @return [String]
    #
    # @!attribute [rw] content_disposition
    #   Specifies presentational information for the object.
    #   @return [String]
    #
    # @!attribute [rw] content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the
    #   media-type referenced by the Content-Type header field.
    #   @return [String]
    #
    # @!attribute [rw] content_language
    #   The language the content is in.
    #   @return [String]
    #
    # @!attribute [rw] content_range
    #   The portion of the object returned in the response.
    #   @return [String]
    #
    # @!attribute [rw] content_type
    #   A standard MIME type describing the format of the object data.
    #   @return [String]
    #
    # @!attribute [rw] expires
    #   The date and time at which the object is no longer cacheable.
    #   @return [Time]
    #
    # @!attribute [rw] expires_string
    #   @return [String]
    #
    # @!attribute [rw] website_redirect_location
    #   If the bucket is configured as a website, redirects requests for
    #   this object to another object in the same bucket or to an external
    #   URL. Amazon S3 stores the value of this header in the object
    #   metadata.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] metadata
    #   A map of metadata to store with the object in S3.
    #   @return [Hash<String,String>]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] storage_class
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @!attribute [rw] replication_status
    #   @return [String]
    #
    # @!attribute [rw] parts_count
    #   The count of parts this object has.
    #   @return [Integer]
    #
    # @!attribute [rw] tag_count
    #   The number of tags, if any, on the object.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectOutput AWS API Documentation
    #
    class GetObjectOutput < Struct.new(
      :body,
      :delete_marker,
      :accept_ranges,
      :expiration,
      :restore,
      :last_modified,
      :content_length,
      :etag,
      :missing_meta,
      :version_id,
      :cache_control,
      :content_disposition,
      :content_encoding,
      :content_language,
      :content_range,
      :content_type,
      :expires,
      :expires_string,
      :website_redirect_location,
      :server_side_encryption,
      :metadata,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :storage_class,
      :request_charged,
      :replication_status,
      :parts_count,
      :tag_count)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetObjectRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         if_match: "IfMatch",
    #         if_modified_since: Time.now,
    #         if_none_match: "IfNoneMatch",
    #         if_unmodified_since: Time.now,
    #         key: "ObjectKey", # required
    #         range: "Range",
    #         response_cache_control: "ResponseCacheControl",
    #         response_content_disposition: "ResponseContentDisposition",
    #         response_content_encoding: "ResponseContentEncoding",
    #         response_content_language: "ResponseContentLanguage",
    #         response_content_type: "ResponseContentType",
    #         response_expires: Time.now,
    #         version_id: "ObjectVersionId",
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         request_payer: "requester", # accepts requester
    #         part_number: 1,
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] if_match
    #   Return the object only if its entity tag (ETag) is the same as the
    #   one specified, otherwise return a 412 (precondition failed).
    #   @return [String]
    #
    # @!attribute [rw] if_modified_since
    #   Return the object only if it has been modified since the specified
    #   time, otherwise return a 304 (not modified).
    #   @return [Time]
    #
    # @!attribute [rw] if_none_match
    #   Return the object only if its entity tag (ETag) is different from
    #   the one specified, otherwise return a 304 (not modified).
    #   @return [String]
    #
    # @!attribute [rw] if_unmodified_since
    #   Return the object only if it has not been modified since the
    #   specified time, otherwise return a 412 (precondition failed).
    #   @return [Time]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] range
    #   Downloads the specified range bytes of an object. For more
    #   information about the HTTP Range header, go to
    #   http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
    #   @return [String]
    #
    # @!attribute [rw] response_cache_control
    #   Sets the Cache-Control header of the response.
    #   @return [String]
    #
    # @!attribute [rw] response_content_disposition
    #   Sets the Content-Disposition header of the response
    #   @return [String]
    #
    # @!attribute [rw] response_content_encoding
    #   Sets the Content-Encoding header of the response.
    #   @return [String]
    #
    # @!attribute [rw] response_content_language
    #   Sets the Content-Language header of the response.
    #   @return [String]
    #
    # @!attribute [rw] response_content_type
    #   Sets the Content-Type header of the response.
    #   @return [String]
    #
    # @!attribute [rw] response_expires
    #   Sets the Expires header of the response.
    #   @return [Time]
    #
    # @!attribute [rw] version_id
    #   VersionId used to reference a specific version of the object.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @!attribute [rw] part_number
    #   Part number of the object being read. This is a positive integer
    #   between 1 and 10,000. Effectively performs a 'ranged' GET request
    #   for the part specified. Useful for downloading just a part of an
    #   object.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectRequest AWS API Documentation
    #
    class GetObjectRequest < Struct.new(
      :bucket,
      :if_match,
      :if_modified_since,
      :if_none_match,
      :if_unmodified_since,
      :key,
      :range,
      :response_cache_control,
      :response_content_disposition,
      :response_content_encoding,
      :response_content_language,
      :response_content_type,
      :response_expires,
      :version_id,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :request_payer,
      :part_number)
      include Aws::Structure
    end

    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @!attribute [rw] tag_set
    #   @return [Array<Types::Tag>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectTaggingOutput AWS API Documentation
    #
    class GetObjectTaggingOutput < Struct.new(
      :version_id,
      :tag_set)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetObjectTaggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         version_id: "ObjectVersionId",
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectTaggingRequest AWS API Documentation
    #
    class GetObjectTaggingRequest < Struct.new(
      :bucket,
      :key,
      :version_id)
      include Aws::Structure
    end

    # @!attribute [rw] body
    #   @return [IO]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectTorrentOutput AWS API Documentation
    #
    class GetObjectTorrentOutput < Struct.new(
      :body,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetObjectTorrentRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GetObjectTorrentRequest AWS API Documentation
    #
    class GetObjectTorrentRequest < Struct.new(
      :bucket,
      :key,
      :request_payer)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GlacierJobParameters
    #   data as a hash:
    #
    #       {
    #         tier: "Standard", # required, accepts Standard, Bulk, Expedited
    #       }
    #
    # @!attribute [rw] tier
    #   Glacier retrieval tier at which the restore will be processed.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/GlacierJobParameters AWS API Documentation
    #
    class GlacierJobParameters < Struct.new(
      :tier)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Grant
    #   data as a hash:
    #
    #       {
    #         grantee: {
    #           display_name: "DisplayName",
    #           email_address: "EmailAddress",
    #           id: "ID",
    #           type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #           uri: "URI",
    #         },
    #         permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #       }
    #
    # @!attribute [rw] grantee
    #   @return [Types::Grantee]
    #
    # @!attribute [rw] permission
    #   Specifies the permission given to the grantee.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Grant AWS API Documentation
    #
    class Grant < Struct.new(
      :grantee,
      :permission)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Grantee
    #   data as a hash:
    #
    #       {
    #         display_name: "DisplayName",
    #         email_address: "EmailAddress",
    #         id: "ID",
    #         type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #         uri: "URI",
    #       }
    #
    # @!attribute [rw] display_name
    #   Screen name of the grantee.
    #   @return [String]
    #
    # @!attribute [rw] email_address
    #   Email address of the grantee.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The canonical user ID of the grantee.
    #   @return [String]
    #
    # @!attribute [rw] type
    #   Type of grantee
    #   @return [String]
    #
    # @!attribute [rw] uri
    #   URI of the grantee group.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Grantee AWS API Documentation
    #
    class Grantee < Struct.new(
      :display_name,
      :email_address,
      :id,
      :type,
      :uri)
      include Aws::Structure
    end

    # @note When making an API call, you may pass HeadBucketRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/HeadBucketRequest AWS API Documentation
    #
    class HeadBucketRequest < Struct.new(
      :bucket)
      include Aws::Structure
    end

    # @!attribute [rw] delete_marker
    #   Specifies whether the object retrieved was (true) or was not (false)
    #   a Delete Marker. If false, this response header does not appear in
    #   the response.
    #   @return [Boolean]
    #
    # @!attribute [rw] accept_ranges
    #   @return [String]
    #
    # @!attribute [rw] expiration
    #   If the object expiration is configured (see PUT Bucket lifecycle),
    #   the response includes this header. It includes the expiry-date and
    #   rule-id key value pairs providing object expiration information. The
    #   value of the rule-id is URL encoded.
    #   @return [String]
    #
    # @!attribute [rw] restore
    #   Provides information about object restoration operation and
    #   expiration time of the restored object copy.
    #   @return [String]
    #
    # @!attribute [rw] last_modified
    #   Last modified date of the object
    #   @return [Time]
    #
    # @!attribute [rw] content_length
    #   Size of the body in bytes.
    #   @return [Integer]
    #
    # @!attribute [rw] etag
    #   An ETag is an opaque identifier assigned by a web server to a
    #   specific version of a resource found at a URL
    #   @return [String]
    #
    # @!attribute [rw] missing_meta
    #   This is set to the number of metadata entries not returned in
    #   x-amz-meta headers. This can happen if you create metadata using an
    #   API like SOAP that supports more flexible metadata than the REST
    #   API. For example, using SOAP, you can create metadata whose values
    #   are not legal HTTP headers.
    #   @return [Integer]
    #
    # @!attribute [rw] version_id
    #   Version of the object.
    #   @return [String]
    #
    # @!attribute [rw] cache_control
    #   Specifies caching behavior along the request/reply chain.
    #   @return [String]
    #
    # @!attribute [rw] content_disposition
    #   Specifies presentational information for the object.
    #   @return [String]
    #
    # @!attribute [rw] content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the
    #   media-type referenced by the Content-Type header field.
    #   @return [String]
    #
    # @!attribute [rw] content_language
    #   The language the content is in.
    #   @return [String]
    #
    # @!attribute [rw] content_type
    #   A standard MIME type describing the format of the object data.
    #   @return [String]
    #
    # @!attribute [rw] expires
    #   The date and time at which the object is no longer cacheable.
    #   @return [Time]
    #
    # @!attribute [rw] expires_string
    #   @return [String]
    #
    # @!attribute [rw] website_redirect_location
    #   If the bucket is configured as a website, redirects requests for
    #   this object to another object in the same bucket or to an external
    #   URL. Amazon S3 stores the value of this header in the object
    #   metadata.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] metadata
    #   A map of metadata to store with the object in S3.
    #   @return [Hash<String,String>]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] storage_class
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @!attribute [rw] replication_status
    #   @return [String]
    #
    # @!attribute [rw] parts_count
    #   The count of parts this object has.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/HeadObjectOutput AWS API Documentation
    #
    class HeadObjectOutput < Struct.new(
      :delete_marker,
      :accept_ranges,
      :expiration,
      :restore,
      :last_modified,
      :content_length,
      :etag,
      :missing_meta,
      :version_id,
      :cache_control,
      :content_disposition,
      :content_encoding,
      :content_language,
      :content_type,
      :expires,
      :expires_string,
      :website_redirect_location,
      :server_side_encryption,
      :metadata,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :storage_class,
      :request_charged,
      :replication_status,
      :parts_count)
      include Aws::Structure
    end

    # @note When making an API call, you may pass HeadObjectRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         if_match: "IfMatch",
    #         if_modified_since: Time.now,
    #         if_none_match: "IfNoneMatch",
    #         if_unmodified_since: Time.now,
    #         key: "ObjectKey", # required
    #         range: "Range",
    #         version_id: "ObjectVersionId",
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         request_payer: "requester", # accepts requester
    #         part_number: 1,
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] if_match
    #   Return the object only if its entity tag (ETag) is the same as the
    #   one specified, otherwise return a 412 (precondition failed).
    #   @return [String]
    #
    # @!attribute [rw] if_modified_since
    #   Return the object only if it has been modified since the specified
    #   time, otherwise return a 304 (not modified).
    #   @return [Time]
    #
    # @!attribute [rw] if_none_match
    #   Return the object only if its entity tag (ETag) is different from
    #   the one specified, otherwise return a 304 (not modified).
    #   @return [String]
    #
    # @!attribute [rw] if_unmodified_since
    #   Return the object only if it has not been modified since the
    #   specified time, otherwise return a 412 (precondition failed).
    #   @return [Time]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] range
    #   Downloads the specified range bytes of an object. For more
    #   information about the HTTP Range header, go to
    #   http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   VersionId used to reference a specific version of the object.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @!attribute [rw] part_number
    #   Part number of the object being read. This is a positive integer
    #   between 1 and 10,000. Effectively performs a 'ranged' HEAD request
    #   for the part specified. Useful querying about the size of the part
    #   and the number of parts in this object.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/HeadObjectRequest AWS API Documentation
    #
    class HeadObjectRequest < Struct.new(
      :bucket,
      :if_match,
      :if_modified_since,
      :if_none_match,
      :if_unmodified_since,
      :key,
      :range,
      :version_id,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :request_payer,
      :part_number)
      include Aws::Structure
    end

    # @note When making an API call, you may pass IndexDocument
    #   data as a hash:
    #
    #       {
    #         suffix: "Suffix", # required
    #       }
    #
    # @!attribute [rw] suffix
    #   A suffix that is appended to a request that is for a directory on
    #   the website endpoint (e.g. if the suffix is index.html and you make
    #   a request to samplebucket/images/ the data that is returned will be
    #   for the object with the key name images/index.html) The suffix must
    #   not be empty and must not include a slash character.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/IndexDocument AWS API Documentation
    #
    class IndexDocument < Struct.new(
      :suffix)
      include Aws::Structure
    end

    # @!attribute [rw] id
    #   If the principal is an AWS account, it provides the Canonical User
    #   ID. If the principal is an IAM User, it provides a user ARN value.
    #   @return [String]
    #
    # @!attribute [rw] display_name
    #   Name of the Principal.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Initiator AWS API Documentation
    #
    class Initiator < Struct.new(
      :id,
      :display_name)
      include Aws::Structure
    end

    # Describes the serialization format of the object.
    #
    # @note When making an API call, you may pass InputSerialization
    #   data as a hash:
    #
    #       {
    #         csv: {
    #           file_header_info: "USE", # accepts USE, IGNORE, NONE
    #           comments: "Comments",
    #           quote_escape_character: "QuoteEscapeCharacter",
    #           record_delimiter: "RecordDelimiter",
    #           field_delimiter: "FieldDelimiter",
    #           quote_character: "QuoteCharacter",
    #         },
    #         compression_type: "NONE", # accepts NONE, GZIP
    #         json: {
    #           type: "DOCUMENT", # accepts DOCUMENT, LINES
    #         },
    #       }
    #
    # @!attribute [rw] csv
    #   Describes the serialization of a CSV-encoded object.
    #   @return [Types::CSVInput]
    #
    # @!attribute [rw] compression_type
    #   Specifies object's compression format. Valid values: NONE, GZIP.
    #   Default Value: NONE.
    #   @return [String]
    #
    # @!attribute [rw] json
    #   Specifies JSON as object's input serialization format.
    #   @return [Types::JSONInput]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InputSerialization AWS API Documentation
    #
    class InputSerialization < Struct.new(
      :csv,
      :compression_type,
      :json)
      include Aws::Structure
    end

    # @note When making an API call, you may pass InventoryConfiguration
    #   data as a hash:
    #
    #       {
    #         destination: { # required
    #           s3_bucket_destination: { # required
    #             account_id: "AccountId",
    #             bucket: "BucketName", # required
    #             format: "CSV", # required, accepts CSV, ORC
    #             prefix: "Prefix",
    #             encryption: {
    #               sses3: {
    #               },
    #               ssekms: {
    #                 key_id: "SSEKMSKeyId", # required
    #               },
    #             },
    #           },
    #         },
    #         is_enabled: false, # required
    #         filter: {
    #           prefix: "Prefix", # required
    #         },
    #         id: "InventoryId", # required
    #         included_object_versions: "All", # required, accepts All, Current
    #         optional_fields: ["Size"], # accepts Size, LastModifiedDate, StorageClass, ETag, IsMultipartUploaded, ReplicationStatus, EncryptionStatus
    #         schedule: { # required
    #           frequency: "Daily", # required, accepts Daily, Weekly
    #         },
    #       }
    #
    # @!attribute [rw] destination
    #   Contains information about where to publish the inventory results.
    #   @return [Types::InventoryDestination]
    #
    # @!attribute [rw] is_enabled
    #   Specifies whether the inventory is enabled or disabled.
    #   @return [Boolean]
    #
    # @!attribute [rw] filter
    #   Specifies an inventory filter. The inventory only includes objects
    #   that meet the filter's criteria.
    #   @return [Types::InventoryFilter]
    #
    # @!attribute [rw] id
    #   The ID used to identify the inventory configuration.
    #   @return [String]
    #
    # @!attribute [rw] included_object_versions
    #   Specifies which object version(s) to included in the inventory
    #   results.
    #   @return [String]
    #
    # @!attribute [rw] optional_fields
    #   Contains the optional fields that are included in the inventory
    #   results.
    #   @return [Array<String>]
    #
    # @!attribute [rw] schedule
    #   Specifies the schedule for generating inventory results.
    #   @return [Types::InventorySchedule]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InventoryConfiguration AWS API Documentation
    #
    class InventoryConfiguration < Struct.new(
      :destination,
      :is_enabled,
      :filter,
      :id,
      :included_object_versions,
      :optional_fields,
      :schedule)
      include Aws::Structure
    end

    # @note When making an API call, you may pass InventoryDestination
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] s3_bucket_destination
    #   Contains the bucket name, file format, bucket owner (optional), and
    #   prefix (optional) where inventory results are published.
    #   @return [Types::InventoryS3BucketDestination]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InventoryDestination AWS API Documentation
    #
    class InventoryDestination < Struct.new(
      :s3_bucket_destination)
      include Aws::Structure
    end

    # Contains the type of server-side encryption used to encrypt the
    # inventory results.
    #
    # @note When making an API call, you may pass InventoryEncryption
    #   data as a hash:
    #
    #       {
    #         sses3: {
    #         },
    #         ssekms: {
    #           key_id: "SSEKMSKeyId", # required
    #         },
    #       }
    #
    # @!attribute [rw] sses3
    #   Specifies the use of SSE-S3 to encrypt delievered Inventory reports.
    #   @return [Types::SSES3]
    #
    # @!attribute [rw] ssekms
    #   Specifies the use of SSE-KMS to encrypt delievered Inventory
    #   reports.
    #   @return [Types::SSEKMS]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InventoryEncryption AWS API Documentation
    #
    class InventoryEncryption < Struct.new(
      :sses3,
      :ssekms)
      include Aws::Structure
    end

    # @note When making an API call, you may pass InventoryFilter
    #   data as a hash:
    #
    #       {
    #         prefix: "Prefix", # required
    #       }
    #
    # @!attribute [rw] prefix
    #   The prefix that an object must have to be included in the inventory
    #   results.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InventoryFilter AWS API Documentation
    #
    class InventoryFilter < Struct.new(
      :prefix)
      include Aws::Structure
    end

    # @note When making an API call, you may pass InventoryS3BucketDestination
    #   data as a hash:
    #
    #       {
    #         account_id: "AccountId",
    #         bucket: "BucketName", # required
    #         format: "CSV", # required, accepts CSV, ORC
    #         prefix: "Prefix",
    #         encryption: {
    #           sses3: {
    #           },
    #           ssekms: {
    #             key_id: "SSEKMSKeyId", # required
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] account_id
    #   The ID of the account that owns the destination bucket.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   The Amazon resource name (ARN) of the bucket where inventory results
    #   will be published.
    #   @return [String]
    #
    # @!attribute [rw] format
    #   Specifies the output format of the inventory results.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   The prefix that is prepended to all inventory results.
    #   @return [String]
    #
    # @!attribute [rw] encryption
    #   Contains the type of server-side encryption used to encrypt the
    #   inventory results.
    #   @return [Types::InventoryEncryption]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InventoryS3BucketDestination AWS API Documentation
    #
    class InventoryS3BucketDestination < Struct.new(
      :account_id,
      :bucket,
      :format,
      :prefix,
      :encryption)
      include Aws::Structure
    end

    # @note When making an API call, you may pass InventorySchedule
    #   data as a hash:
    #
    #       {
    #         frequency: "Daily", # required, accepts Daily, Weekly
    #       }
    #
    # @!attribute [rw] frequency
    #   Specifies how frequently inventory results are produced.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/InventorySchedule AWS API Documentation
    #
    class InventorySchedule < Struct.new(
      :frequency)
      include Aws::Structure
    end

    # @note When making an API call, you may pass JSONInput
    #   data as a hash:
    #
    #       {
    #         type: "DOCUMENT", # accepts DOCUMENT, LINES
    #       }
    #
    # @!attribute [rw] type
    #   The type of JSON. Valid values: Document, Lines.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/JSONInput AWS API Documentation
    #
    class JSONInput < Struct.new(
      :type)
      include Aws::Structure
    end

    # @note When making an API call, you may pass JSONOutput
    #   data as a hash:
    #
    #       {
    #         record_delimiter: "RecordDelimiter",
    #       }
    #
    # @!attribute [rw] record_delimiter
    #   The value used to separate individual records in the output.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/JSONOutput AWS API Documentation
    #
    class JSONOutput < Struct.new(
      :record_delimiter)
      include Aws::Structure
    end

    # Container for specifying the AWS Lambda notification configuration.
    #
    # @note When making an API call, you may pass LambdaFunctionConfiguration
    #   data as a hash:
    #
    #       {
    #         id: "NotificationId",
    #         lambda_function_arn: "LambdaFunctionArn", # required
    #         events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         filter: {
    #           key: {
    #             filter_rules: [
    #               {
    #                 name: "prefix", # accepts prefix, suffix
    #                 value: "FilterRuleValue",
    #               },
    #             ],
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] id
    #   Optional unique identifier for configurations in a notification
    #   configuration. If you don't provide one, Amazon S3 will assign an
    #   ID.
    #   @return [String]
    #
    # @!attribute [rw] lambda_function_arn
    #   Lambda cloud function ARN that Amazon S3 can invoke when it detects
    #   events of the specified type.
    #   @return [String]
    #
    # @!attribute [rw] events
    #   @return [Array<String>]
    #
    # @!attribute [rw] filter
    #   Container for object key name filtering rules. For information about
    #   key name filtering, go to [Configuring Event Notifications][1] in
    #   the Amazon Simple Storage Service Developer Guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
    #   @return [Types::NotificationConfigurationFilter]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LambdaFunctionConfiguration AWS API Documentation
    #
    class LambdaFunctionConfiguration < Struct.new(
      :id,
      :lambda_function_arn,
      :events,
      :filter)
      include Aws::Structure
    end

    # @note When making an API call, you may pass LifecycleConfiguration
    #   data as a hash:
    #
    #       {
    #         rules: [ # required
    #           {
    #             expiration: {
    #               date: Time.now,
    #               days: 1,
    #               expired_object_delete_marker: false,
    #             },
    #             id: "ID",
    #             prefix: "Prefix", # required
    #             status: "Enabled", # required, accepts Enabled, Disabled
    #             transition: {
    #               date: Time.now,
    #               days: 1,
    #               storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #             },
    #             noncurrent_version_transition: {
    #               noncurrent_days: 1,
    #               storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #             },
    #             noncurrent_version_expiration: {
    #               noncurrent_days: 1,
    #             },
    #             abort_incomplete_multipart_upload: {
    #               days_after_initiation: 1,
    #             },
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] rules
    #   @return [Array<Types::Rule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LifecycleConfiguration AWS API Documentation
    #
    class LifecycleConfiguration < Struct.new(
      :rules)
      include Aws::Structure
    end

    # @note When making an API call, you may pass LifecycleExpiration
    #   data as a hash:
    #
    #       {
    #         date: Time.now,
    #         days: 1,
    #         expired_object_delete_marker: false,
    #       }
    #
    # @!attribute [rw] date
    #   Indicates at what date the object is to be moved or deleted. Should
    #   be in GMT ISO 8601 Format.
    #   @return [Time]
    #
    # @!attribute [rw] days
    #   Indicates the lifetime, in days, of the objects that are subject to
    #   the rule. The value must be a non-zero positive integer.
    #   @return [Integer]
    #
    # @!attribute [rw] expired_object_delete_marker
    #   Indicates whether Amazon S3 will remove a delete marker with no
    #   noncurrent versions. If set to true, the delete marker will be
    #   expired; if set to false the policy takes no action. This cannot be
    #   specified with Days or Date in a Lifecycle Expiration Policy.
    #   @return [Boolean]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LifecycleExpiration AWS API Documentation
    #
    class LifecycleExpiration < Struct.new(
      :date,
      :days,
      :expired_object_delete_marker)
      include Aws::Structure
    end

    # @note When making an API call, you may pass LifecycleRule
    #   data as a hash:
    #
    #       {
    #         expiration: {
    #           date: Time.now,
    #           days: 1,
    #           expired_object_delete_marker: false,
    #         },
    #         id: "ID",
    #         prefix: "Prefix",
    #         filter: {
    #           prefix: "Prefix",
    #           tag: {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #           and: {
    #             prefix: "Prefix",
    #             tags: [
    #               {
    #                 key: "ObjectKey", # required
    #                 value: "Value", # required
    #               },
    #             ],
    #           },
    #         },
    #         status: "Enabled", # required, accepts Enabled, Disabled
    #         transitions: [
    #           {
    #             date: Time.now,
    #             days: 1,
    #             storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #           },
    #         ],
    #         noncurrent_version_transitions: [
    #           {
    #             noncurrent_days: 1,
    #             storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #           },
    #         ],
    #         noncurrent_version_expiration: {
    #           noncurrent_days: 1,
    #         },
    #         abort_incomplete_multipart_upload: {
    #           days_after_initiation: 1,
    #         },
    #       }
    #
    # @!attribute [rw] expiration
    #   @return [Types::LifecycleExpiration]
    #
    # @!attribute [rw] id
    #   Unique identifier for the rule. The value cannot be longer than 255
    #   characters.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   Prefix identifying one or more objects to which the rule applies.
    #   This is deprecated; use Filter instead.
    #   @return [String]
    #
    # @!attribute [rw] filter
    #   The Filter is used to identify objects that a Lifecycle Rule applies
    #   to. A Filter must have exactly one of Prefix, Tag, or And specified.
    #   @return [Types::LifecycleRuleFilter]
    #
    # @!attribute [rw] status
    #   If 'Enabled', the rule is currently being applied. If
    #   'Disabled', the rule is not currently being applied.
    #   @return [String]
    #
    # @!attribute [rw] transitions
    #   @return [Array<Types::Transition>]
    #
    # @!attribute [rw] noncurrent_version_transitions
    #   @return [Array<Types::NoncurrentVersionTransition>]
    #
    # @!attribute [rw] noncurrent_version_expiration
    #   Specifies when noncurrent object versions expire. Upon expiration,
    #   Amazon S3 permanently deletes the noncurrent object versions. You
    #   set this lifecycle configuration action on a bucket that has
    #   versioning enabled (or suspended) to request that Amazon S3 delete
    #   noncurrent object versions at a specific period in the object's
    #   lifetime.
    #   @return [Types::NoncurrentVersionExpiration]
    #
    # @!attribute [rw] abort_incomplete_multipart_upload
    #   Specifies the days since the initiation of an Incomplete Multipart
    #   Upload that Lifecycle will wait before permanently removing all
    #   parts of the upload.
    #   @return [Types::AbortIncompleteMultipartUpload]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LifecycleRule AWS API Documentation
    #
    class LifecycleRule < Struct.new(
      :expiration,
      :id,
      :prefix,
      :filter,
      :status,
      :transitions,
      :noncurrent_version_transitions,
      :noncurrent_version_expiration,
      :abort_incomplete_multipart_upload)
      include Aws::Structure
    end

    # This is used in a Lifecycle Rule Filter to apply a logical AND to two
    # or more predicates. The Lifecycle Rule will apply to any object
    # matching all of the predicates configured inside the And operator.
    #
    # @note When making an API call, you may pass LifecycleRuleAndOperator
    #   data as a hash:
    #
    #       {
    #         prefix: "Prefix",
    #         tags: [
    #           {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] prefix
    #   @return [String]
    #
    # @!attribute [rw] tags
    #   All of these tags must exist in the object's tag set in order for
    #   the rule to apply.
    #   @return [Array<Types::Tag>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LifecycleRuleAndOperator AWS API Documentation
    #
    class LifecycleRuleAndOperator < Struct.new(
      :prefix,
      :tags)
      include Aws::Structure
    end

    # The Filter is used to identify objects that a Lifecycle Rule applies
    # to. A Filter must have exactly one of Prefix, Tag, or And specified.
    #
    # @note When making an API call, you may pass LifecycleRuleFilter
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] prefix
    #   Prefix identifying one or more objects to which the rule applies.
    #   @return [String]
    #
    # @!attribute [rw] tag
    #   This tag must exist in the object's tag set in order for the rule
    #   to apply.
    #   @return [Types::Tag]
    #
    # @!attribute [rw] and
    #   This is used in a Lifecycle Rule Filter to apply a logical AND to
    #   two or more predicates. The Lifecycle Rule will apply to any object
    #   matching all of the predicates configured inside the And operator.
    #   @return [Types::LifecycleRuleAndOperator]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LifecycleRuleFilter AWS API Documentation
    #
    class LifecycleRuleFilter < Struct.new(
      :prefix,
      :tag,
      :and)
      include Aws::Structure
    end

    # @!attribute [rw] is_truncated
    #   Indicates whether the returned list of analytics configurations is
    #   complete. A value of true indicates that the list is not complete
    #   and the NextContinuationToken will be provided for a subsequent
    #   request.
    #   @return [Boolean]
    #
    # @!attribute [rw] continuation_token
    #   The ContinuationToken that represents where this request began.
    #   @return [String]
    #
    # @!attribute [rw] next_continuation_token
    #   NextContinuationToken is sent when isTruncated is true, which
    #   indicates that there are more analytics configurations to list. The
    #   next request must include this NextContinuationToken. The token is
    #   obfuscated and is not a usable value.
    #   @return [String]
    #
    # @!attribute [rw] analytics_configuration_list
    #   The list of analytics configurations for a bucket.
    #   @return [Array<Types::AnalyticsConfiguration>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketAnalyticsConfigurationsOutput AWS API Documentation
    #
    class ListBucketAnalyticsConfigurationsOutput < Struct.new(
      :is_truncated,
      :continuation_token,
      :next_continuation_token,
      :analytics_configuration_list)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListBucketAnalyticsConfigurationsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         continuation_token: "Token",
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket from which analytics configurations are
    #   retrieved.
    #   @return [String]
    #
    # @!attribute [rw] continuation_token
    #   The ContinuationToken that represents a placeholder from where this
    #   request should begin.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketAnalyticsConfigurationsRequest AWS API Documentation
    #
    class ListBucketAnalyticsConfigurationsRequest < Struct.new(
      :bucket,
      :continuation_token)
      include Aws::Structure
    end

    # @!attribute [rw] continuation_token
    #   If sent in the request, the marker that is used as a starting point
    #   for this inventory configuration list response.
    #   @return [String]
    #
    # @!attribute [rw] inventory_configuration_list
    #   The list of inventory configurations for a bucket.
    #   @return [Array<Types::InventoryConfiguration>]
    #
    # @!attribute [rw] is_truncated
    #   Indicates whether the returned list of inventory configurations is
    #   truncated in this response. A value of true indicates that the list
    #   is truncated.
    #   @return [Boolean]
    #
    # @!attribute [rw] next_continuation_token
    #   The marker used to continue this inventory configuration listing.
    #   Use the NextContinuationToken from this response to continue the
    #   listing in a subsequent request. The continuation token is an opaque
    #   value that Amazon S3 understands.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketInventoryConfigurationsOutput AWS API Documentation
    #
    class ListBucketInventoryConfigurationsOutput < Struct.new(
      :continuation_token,
      :inventory_configuration_list,
      :is_truncated,
      :next_continuation_token)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListBucketInventoryConfigurationsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         continuation_token: "Token",
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the inventory configurations to
    #   retrieve.
    #   @return [String]
    #
    # @!attribute [rw] continuation_token
    #   The marker used to continue an inventory configuration listing that
    #   has been truncated. Use the NextContinuationToken from a previously
    #   truncated list response to continue the listing. The continuation
    #   token is an opaque value that Amazon S3 understands.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketInventoryConfigurationsRequest AWS API Documentation
    #
    class ListBucketInventoryConfigurationsRequest < Struct.new(
      :bucket,
      :continuation_token)
      include Aws::Structure
    end

    # @!attribute [rw] is_truncated
    #   Indicates whether the returned list of metrics configurations is
    #   complete. A value of true indicates that the list is not complete
    #   and the NextContinuationToken will be provided for a subsequent
    #   request.
    #   @return [Boolean]
    #
    # @!attribute [rw] continuation_token
    #   The marker that is used as a starting point for this metrics
    #   configuration list response. This value is present if it was sent in
    #   the request.
    #   @return [String]
    #
    # @!attribute [rw] next_continuation_token
    #   The marker used to continue a metrics configuration listing that has
    #   been truncated. Use the NextContinuationToken from a previously
    #   truncated list response to continue the listing. The continuation
    #   token is an opaque value that Amazon S3 understands.
    #   @return [String]
    #
    # @!attribute [rw] metrics_configuration_list
    #   The list of metrics configurations for a bucket.
    #   @return [Array<Types::MetricsConfiguration>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketMetricsConfigurationsOutput AWS API Documentation
    #
    class ListBucketMetricsConfigurationsOutput < Struct.new(
      :is_truncated,
      :continuation_token,
      :next_continuation_token,
      :metrics_configuration_list)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListBucketMetricsConfigurationsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         continuation_token: "Token",
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket containing the metrics configurations to
    #   retrieve.
    #   @return [String]
    #
    # @!attribute [rw] continuation_token
    #   The marker that is used to continue a metrics configuration listing
    #   that has been truncated. Use the NextContinuationToken from a
    #   previously truncated list response to continue the listing. The
    #   continuation token is an opaque value that Amazon S3 understands.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketMetricsConfigurationsRequest AWS API Documentation
    #
    class ListBucketMetricsConfigurationsRequest < Struct.new(
      :bucket,
      :continuation_token)
      include Aws::Structure
    end

    # @!attribute [rw] buckets
    #   @return [Array<Types::Bucket>]
    #
    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListBucketsOutput AWS API Documentation
    #
    class ListBucketsOutput < Struct.new(
      :buckets,
      :owner)
      include Aws::Structure
    end

    # @!attribute [rw] bucket
    #   Name of the bucket to which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] key_marker
    #   The key at or after which the listing began.
    #   @return [String]
    #
    # @!attribute [rw] upload_id_marker
    #   Upload ID after which listing began.
    #   @return [String]
    #
    # @!attribute [rw] next_key_marker
    #   When a list is truncated, this element specifies the value that
    #   should be used for the key-marker request parameter in a subsequent
    #   request.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   When a prefix is provided in the request, this field contains the
    #   specified prefix. The result contains only keys starting with the
    #   specified prefix.
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   @return [String]
    #
    # @!attribute [rw] next_upload_id_marker
    #   When a list is truncated, this element specifies the value that
    #   should be used for the upload-id-marker request parameter in a
    #   subsequent request.
    #   @return [String]
    #
    # @!attribute [rw] max_uploads
    #   Maximum number of multipart uploads that could have been included in
    #   the response.
    #   @return [Integer]
    #
    # @!attribute [rw] is_truncated
    #   Indicates whether the returned list of multipart uploads is
    #   truncated. A value of true indicates that the list was truncated.
    #   The list can be truncated if the number of multipart uploads exceeds
    #   the limit allowed or specified by max uploads.
    #   @return [Boolean]
    #
    # @!attribute [rw] uploads
    #   @return [Array<Types::MultipartUpload>]
    #
    # @!attribute [rw] common_prefixes
    #   @return [Array<Types::CommonPrefix>]
    #
    # @!attribute [rw] encoding_type
    #   Encoding type used by Amazon S3 to encode object keys in the
    #   response.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListMultipartUploadsOutput AWS API Documentation
    #
    class ListMultipartUploadsOutput < Struct.new(
      :bucket,
      :key_marker,
      :upload_id_marker,
      :next_key_marker,
      :prefix,
      :delimiter,
      :next_upload_id_marker,
      :max_uploads,
      :is_truncated,
      :uploads,
      :common_prefixes,
      :encoding_type)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListMultipartUploadsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         delimiter: "Delimiter",
    #         encoding_type: "url", # accepts url
    #         key_marker: "KeyMarker",
    #         max_uploads: 1,
    #         prefix: "Prefix",
    #         upload_id_marker: "UploadIdMarker",
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   Character you use to group keys.
    #   @return [String]
    #
    # @!attribute [rw] encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    #   @return [String]
    #
    # @!attribute [rw] key_marker
    #   Together with upload-id-marker, this parameter specifies the
    #   multipart upload after which listing should begin.
    #   @return [String]
    #
    # @!attribute [rw] max_uploads
    #   Sets the maximum number of multipart uploads, from 1 to 1,000, to
    #   return in the response body. 1,000 is the maximum number of uploads
    #   that can be returned in a response.
    #   @return [Integer]
    #
    # @!attribute [rw] prefix
    #   Lists in-progress uploads only for those keys that begin with the
    #   specified prefix.
    #   @return [String]
    #
    # @!attribute [rw] upload_id_marker
    #   Together with key-marker, specifies the multipart upload after which
    #   listing should begin. If key-marker is not specified, the
    #   upload-id-marker parameter is ignored.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListMultipartUploadsRequest AWS API Documentation
    #
    class ListMultipartUploadsRequest < Struct.new(
      :bucket,
      :delimiter,
      :encoding_type,
      :key_marker,
      :max_uploads,
      :prefix,
      :upload_id_marker)
      include Aws::Structure
    end

    # @!attribute [rw] is_truncated
    #   A flag that indicates whether or not Amazon S3 returned all of the
    #   results that satisfied the search criteria. If your results were
    #   truncated, you can make a follow-up paginated request using the
    #   NextKeyMarker and NextVersionIdMarker response parameters as a
    #   starting place in another request to return the rest of the results.
    #   @return [Boolean]
    #
    # @!attribute [rw] key_marker
    #   Marks the last Key returned in a truncated response.
    #   @return [String]
    #
    # @!attribute [rw] version_id_marker
    #   @return [String]
    #
    # @!attribute [rw] next_key_marker
    #   Use this value for the key marker request parameter in a subsequent
    #   request.
    #   @return [String]
    #
    # @!attribute [rw] next_version_id_marker
    #   Use this value for the next version id marker parameter in a
    #   subsequent request.
    #   @return [String]
    #
    # @!attribute [rw] versions
    #   @return [Array<Types::ObjectVersion>]
    #
    # @!attribute [rw] delete_markers
    #   @return [Array<Types::DeleteMarkerEntry>]
    #
    # @!attribute [rw] name
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   @return [String]
    #
    # @!attribute [rw] max_keys
    #   @return [Integer]
    #
    # @!attribute [rw] common_prefixes
    #   @return [Array<Types::CommonPrefix>]
    #
    # @!attribute [rw] encoding_type
    #   Encoding type used by Amazon S3 to encode object keys in the
    #   response.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectVersionsOutput AWS API Documentation
    #
    class ListObjectVersionsOutput < Struct.new(
      :is_truncated,
      :key_marker,
      :version_id_marker,
      :next_key_marker,
      :next_version_id_marker,
      :versions,
      :delete_markers,
      :name,
      :prefix,
      :delimiter,
      :max_keys,
      :common_prefixes,
      :encoding_type)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListObjectVersionsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         delimiter: "Delimiter",
    #         encoding_type: "url", # accepts url
    #         key_marker: "KeyMarker",
    #         max_keys: 1,
    #         prefix: "Prefix",
    #         version_id_marker: "VersionIdMarker",
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   A delimiter is a character you use to group keys.
    #   @return [String]
    #
    # @!attribute [rw] encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    #   @return [String]
    #
    # @!attribute [rw] key_marker
    #   Specifies the key to start with when listing objects in a bucket.
    #   @return [String]
    #
    # @!attribute [rw] max_keys
    #   Sets the maximum number of keys returned in the response. The
    #   response might contain fewer keys but will never contain more.
    #   @return [Integer]
    #
    # @!attribute [rw] prefix
    #   Limits the response to keys that begin with the specified prefix.
    #   @return [String]
    #
    # @!attribute [rw] version_id_marker
    #   Specifies the object version you want to start listing from.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectVersionsRequest AWS API Documentation
    #
    class ListObjectVersionsRequest < Struct.new(
      :bucket,
      :delimiter,
      :encoding_type,
      :key_marker,
      :max_keys,
      :prefix,
      :version_id_marker)
      include Aws::Structure
    end

    # @!attribute [rw] is_truncated
    #   A flag that indicates whether or not Amazon S3 returned all of the
    #   results that satisfied the search criteria.
    #   @return [Boolean]
    #
    # @!attribute [rw] marker
    #   @return [String]
    #
    # @!attribute [rw] next_marker
    #   When response is truncated (the IsTruncated element value in the
    #   response is true), you can use the key name in this field as marker
    #   in the subsequent request to get next set of objects. Amazon S3
    #   lists objects in alphabetical order Note: This element is returned
    #   only if you have delimiter request parameter specified. If response
    #   does not include the NextMaker and it is truncated, you can use the
    #   value of the last Key in the response as the marker in the
    #   subsequent request to get the next set of object keys.
    #   @return [String]
    #
    # @!attribute [rw] contents
    #   @return [Array<Types::Object>]
    #
    # @!attribute [rw] name
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   @return [String]
    #
    # @!attribute [rw] max_keys
    #   @return [Integer]
    #
    # @!attribute [rw] common_prefixes
    #   @return [Array<Types::CommonPrefix>]
    #
    # @!attribute [rw] encoding_type
    #   Encoding type used by Amazon S3 to encode object keys in the
    #   response.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectsOutput AWS API Documentation
    #
    class ListObjectsOutput < Struct.new(
      :is_truncated,
      :marker,
      :next_marker,
      :contents,
      :name,
      :prefix,
      :delimiter,
      :max_keys,
      :common_prefixes,
      :encoding_type)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListObjectsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         delimiter: "Delimiter",
    #         encoding_type: "url", # accepts url
    #         marker: "Marker",
    #         max_keys: 1,
    #         prefix: "Prefix",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   A delimiter is a character you use to group keys.
    #   @return [String]
    #
    # @!attribute [rw] encoding_type
    #   Requests Amazon S3 to encode the object keys in the response and
    #   specifies the encoding method to use. An object key may contain any
    #   Unicode character; however, XML 1.0 parser cannot parse some
    #   characters, such as characters with an ASCII value from 0 to 10. For
    #   characters that are not supported in XML 1.0, you can add this
    #   parameter to request that Amazon S3 encode the keys in the response.
    #   @return [String]
    #
    # @!attribute [rw] marker
    #   Specifies the key to start with when listing objects in a bucket.
    #   @return [String]
    #
    # @!attribute [rw] max_keys
    #   Sets the maximum number of keys returned in the response. The
    #   response might contain fewer keys but will never contain more.
    #   @return [Integer]
    #
    # @!attribute [rw] prefix
    #   Limits the response to keys that begin with the specified prefix.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the list objects request. Bucket owners need not specify this
    #   parameter in their requests.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectsRequest AWS API Documentation
    #
    class ListObjectsRequest < Struct.new(
      :bucket,
      :delimiter,
      :encoding_type,
      :marker,
      :max_keys,
      :prefix,
      :request_payer)
      include Aws::Structure
    end

    # @!attribute [rw] is_truncated
    #   A flag that indicates whether or not Amazon S3 returned all of the
    #   results that satisfied the search criteria.
    #   @return [Boolean]
    #
    # @!attribute [rw] contents
    #   Metadata about each object returned.
    #   @return [Array<Types::Object>]
    #
    # @!attribute [rw] name
    #   Name of the bucket to list.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   Limits the response to keys that begin with the specified prefix.
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   A delimiter is a character you use to group keys.
    #   @return [String]
    #
    # @!attribute [rw] max_keys
    #   Sets the maximum number of keys returned in the response. The
    #   response might contain fewer keys but will never contain more.
    #   @return [Integer]
    #
    # @!attribute [rw] common_prefixes
    #   CommonPrefixes contains all (if there are any) keys between Prefix
    #   and the next occurrence of the string specified by delimiter
    #   @return [Array<Types::CommonPrefix>]
    #
    # @!attribute [rw] encoding_type
    #   Encoding type used by Amazon S3 to encode object keys in the
    #   response.
    #   @return [String]
    #
    # @!attribute [rw] key_count
    #   KeyCount is the number of keys returned with this request. KeyCount
    #   will always be less than equals to MaxKeys field. Say you ask for 50
    #   keys, your result will include less than equals 50 keys
    #   @return [Integer]
    #
    # @!attribute [rw] continuation_token
    #   ContinuationToken indicates Amazon S3 that the list is being
    #   continued on this bucket with a token. ContinuationToken is
    #   obfuscated and is not a real key
    #   @return [String]
    #
    # @!attribute [rw] next_continuation_token
    #   NextContinuationToken is sent when isTruncated is true which means
    #   there are more keys in the bucket that can be listed. The next list
    #   requests to Amazon S3 can be continued with this
    #   NextContinuationToken. NextContinuationToken is obfuscated and is
    #   not a real key
    #   @return [String]
    #
    # @!attribute [rw] start_after
    #   StartAfter is where you want Amazon S3 to start listing from. Amazon
    #   S3 starts listing after this specified key. StartAfter can be any
    #   key in the bucket
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectsV2Output AWS API Documentation
    #
    class ListObjectsV2Output < Struct.new(
      :is_truncated,
      :contents,
      :name,
      :prefix,
      :delimiter,
      :max_keys,
      :common_prefixes,
      :encoding_type,
      :key_count,
      :continuation_token,
      :next_continuation_token,
      :start_after)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListObjectsV2Request
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         delimiter: "Delimiter",
    #         encoding_type: "url", # accepts url
    #         max_keys: 1,
    #         prefix: "Prefix",
    #         continuation_token: "Token",
    #         fetch_owner: false,
    #         start_after: "StartAfter",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   Name of the bucket to list.
    #   @return [String]
    #
    # @!attribute [rw] delimiter
    #   A delimiter is a character you use to group keys.
    #   @return [String]
    #
    # @!attribute [rw] encoding_type
    #   Encoding type used by Amazon S3 to encode object keys in the
    #   response.
    #   @return [String]
    #
    # @!attribute [rw] max_keys
    #   Sets the maximum number of keys returned in the response. The
    #   response might contain fewer keys but will never contain more.
    #   @return [Integer]
    #
    # @!attribute [rw] prefix
    #   Limits the response to keys that begin with the specified prefix.
    #   @return [String]
    #
    # @!attribute [rw] continuation_token
    #   ContinuationToken indicates Amazon S3 that the list is being
    #   continued on this bucket with a token. ContinuationToken is
    #   obfuscated and is not a real key
    #   @return [String]
    #
    # @!attribute [rw] fetch_owner
    #   The owner field is not present in listV2 by default, if you want to
    #   return owner field with each key in the result then set the fetch
    #   owner field to true
    #   @return [Boolean]
    #
    # @!attribute [rw] start_after
    #   StartAfter is where you want Amazon S3 to start listing from. Amazon
    #   S3 starts listing after this specified key. StartAfter can be any
    #   key in the bucket
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the list objects request in V2 style. Bucket owners need not specify
    #   this parameter in their requests.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListObjectsV2Request AWS API Documentation
    #
    class ListObjectsV2Request < Struct.new(
      :bucket,
      :delimiter,
      :encoding_type,
      :max_keys,
      :prefix,
      :continuation_token,
      :fetch_owner,
      :start_after,
      :request_payer)
      include Aws::Structure
    end

    # @!attribute [rw] abort_date
    #   Date when multipart upload will become eligible for abort operation
    #   by lifecycle.
    #   @return [Time]
    #
    # @!attribute [rw] abort_rule_id
    #   Id of the lifecycle rule that makes a multipart upload eligible for
    #   abort operation.
    #   @return [String]
    #
    # @!attribute [rw] bucket
    #   Name of the bucket to which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   Object key for which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] upload_id
    #   Upload ID identifying the multipart upload whose parts are being
    #   listed.
    #   @return [String]
    #
    # @!attribute [rw] part_number_marker
    #   Part number after which listing begins.
    #   @return [Integer]
    #
    # @!attribute [rw] next_part_number_marker
    #   When a list is truncated, this element specifies the last part in
    #   the list, as well as the value to use for the part-number-marker
    #   request parameter in a subsequent request.
    #   @return [Integer]
    #
    # @!attribute [rw] max_parts
    #   Maximum number of parts that were allowed in the response.
    #   @return [Integer]
    #
    # @!attribute [rw] is_truncated
    #   Indicates whether the returned list of parts is truncated.
    #   @return [Boolean]
    #
    # @!attribute [rw] parts
    #   @return [Array<Types::Part>]
    #
    # @!attribute [rw] initiator
    #   Identifies who initiated the multipart upload.
    #   @return [Types::Initiator]
    #
    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListPartsOutput AWS API Documentation
    #
    class ListPartsOutput < Struct.new(
      :abort_date,
      :abort_rule_id,
      :bucket,
      :key,
      :upload_id,
      :part_number_marker,
      :next_part_number_marker,
      :max_parts,
      :is_truncated,
      :parts,
      :initiator,
      :owner,
      :storage_class,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ListPartsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         max_parts: 1,
    #         part_number_marker: 1,
    #         upload_id: "MultipartUploadId", # required
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] max_parts
    #   Sets the maximum number of parts to return.
    #   @return [Integer]
    #
    # @!attribute [rw] part_number_marker
    #   Specifies the part after which listing should begin. Only parts with
    #   higher part numbers will be listed.
    #   @return [Integer]
    #
    # @!attribute [rw] upload_id
    #   Upload ID identifying the multipart upload whose parts are being
    #   listed.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ListPartsRequest AWS API Documentation
    #
    class ListPartsRequest < Struct.new(
      :bucket,
      :key,
      :max_parts,
      :part_number_marker,
      :upload_id,
      :request_payer)
      include Aws::Structure
    end

    # Container for logging information. Presence of this element indicates
    # that logging is enabled. Parameters TargetBucket and TargetPrefix are
    # required in this case.
    #
    # @note When making an API call, you may pass LoggingEnabled
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] target_bucket
    #   Specifies the bucket where you want Amazon S3 to store server access
    #   logs. You can have your logs delivered to any bucket that you own,
    #   including the same bucket that is being logged. You can also
    #   configure multiple buckets to deliver their logs to the same target
    #   bucket. In this case you should choose a different TargetPrefix for
    #   each source bucket so that the delivered log files can be
    #   distinguished by key.
    #   @return [String]
    #
    # @!attribute [rw] target_grants
    #   @return [Array<Types::TargetGrant>]
    #
    # @!attribute [rw] target_prefix
    #   This element lets you specify a prefix for the keys that the log
    #   files will be stored under.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/LoggingEnabled AWS API Documentation
    #
    class LoggingEnabled < Struct.new(
      :target_bucket,
      :target_grants,
      :target_prefix)
      include Aws::Structure
    end

    # A metadata key-value pair to store with an object.
    #
    # @note When making an API call, you may pass MetadataEntry
    #   data as a hash:
    #
    #       {
    #         name: "MetadataKey",
    #         value: "MetadataValue",
    #       }
    #
    # @!attribute [rw] name
    #   @return [String]
    #
    # @!attribute [rw] value
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/MetadataEntry AWS API Documentation
    #
    class MetadataEntry < Struct.new(
      :name,
      :value)
      include Aws::Structure
    end

    # @note When making an API call, you may pass MetricsAndOperator
    #   data as a hash:
    #
    #       {
    #         prefix: "Prefix",
    #         tags: [
    #           {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] prefix
    #   The prefix used when evaluating an AND predicate.
    #   @return [String]
    #
    # @!attribute [rw] tags
    #   The list of tags used when evaluating an AND predicate.
    #   @return [Array<Types::Tag>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/MetricsAndOperator AWS API Documentation
    #
    class MetricsAndOperator < Struct.new(
      :prefix,
      :tags)
      include Aws::Structure
    end

    # @note When making an API call, you may pass MetricsConfiguration
    #   data as a hash:
    #
    #       {
    #         id: "MetricsId", # required
    #         filter: {
    #           prefix: "Prefix",
    #           tag: {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #           and: {
    #             prefix: "Prefix",
    #             tags: [
    #               {
    #                 key: "ObjectKey", # required
    #                 value: "Value", # required
    #               },
    #             ],
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] id
    #   The ID used to identify the metrics configuration.
    #   @return [String]
    #
    # @!attribute [rw] filter
    #   Specifies a metrics configuration filter. The metrics configuration
    #   will only include objects that meet the filter's criteria. A filter
    #   must be a prefix, a tag, or a conjunction (MetricsAndOperator).
    #   @return [Types::MetricsFilter]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/MetricsConfiguration AWS API Documentation
    #
    class MetricsConfiguration < Struct.new(
      :id,
      :filter)
      include Aws::Structure
    end

    # @note When making an API call, you may pass MetricsFilter
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] prefix
    #   The prefix used when evaluating a metrics filter.
    #   @return [String]
    #
    # @!attribute [rw] tag
    #   The tag used when evaluating a metrics filter.
    #   @return [Types::Tag]
    #
    # @!attribute [rw] and
    #   A conjunction (logical AND) of predicates, which is used in
    #   evaluating a metrics filter. The operator must have at least two
    #   predicates, and an object must match all of the predicates in order
    #   for the filter to apply.
    #   @return [Types::MetricsAndOperator]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/MetricsFilter AWS API Documentation
    #
    class MetricsFilter < Struct.new(
      :prefix,
      :tag,
      :and)
      include Aws::Structure
    end

    # @!attribute [rw] upload_id
    #   Upload ID that identifies the multipart upload.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   Key of the object for which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] initiated
    #   Date and time at which the multipart upload was initiated.
    #   @return [Time]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @!attribute [rw] initiator
    #   Identifies who initiated the multipart upload.
    #   @return [Types::Initiator]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/MultipartUpload AWS API Documentation
    #
    class MultipartUpload < Struct.new(
      :upload_id,
      :key,
      :initiated,
      :storage_class,
      :owner,
      :initiator)
      include Aws::Structure
    end

    # Specifies when noncurrent object versions expire. Upon expiration,
    # Amazon S3 permanently deletes the noncurrent object versions. You set
    # this lifecycle configuration action on a bucket that has versioning
    # enabled (or suspended) to request that Amazon S3 delete noncurrent
    # object versions at a specific period in the object's lifetime.
    #
    # @note When making an API call, you may pass NoncurrentVersionExpiration
    #   data as a hash:
    #
    #       {
    #         noncurrent_days: 1,
    #       }
    #
    # @!attribute [rw] noncurrent_days
    #   Specifies the number of days an object is noncurrent before Amazon
    #   S3 can perform the associated action. For information about the
    #   noncurrent days calculations, see [How Amazon S3 Calculates When an
    #   Object Became Noncurrent][1] in the Amazon Simple Storage Service
    #   Developer Guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/s3-access-control.html
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/NoncurrentVersionExpiration AWS API Documentation
    #
    class NoncurrentVersionExpiration < Struct.new(
      :noncurrent_days)
      include Aws::Structure
    end

    # Container for the transition rule that describes when noncurrent
    # objects transition to the STANDARD\_IA, ONEZONE\_IA or GLACIER storage
    # class. If your bucket is versioning-enabled (or versioning is
    # suspended), you can set this action to request that Amazon S3
    # transition noncurrent object versions to the STANDARD\_IA, ONEZONE\_IA
    # or GLACIER storage class at a specific period in the object's
    # lifetime.
    #
    # @note When making an API call, you may pass NoncurrentVersionTransition
    #   data as a hash:
    #
    #       {
    #         noncurrent_days: 1,
    #         storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #       }
    #
    # @!attribute [rw] noncurrent_days
    #   Specifies the number of days an object is noncurrent before Amazon
    #   S3 can perform the associated action. For information about the
    #   noncurrent days calculations, see [How Amazon S3 Calculates When an
    #   Object Became Noncurrent][1] in the Amazon Simple Storage Service
    #   Developer Guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/s3-access-control.html
    #   @return [Integer]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/NoncurrentVersionTransition AWS API Documentation
    #
    class NoncurrentVersionTransition < Struct.new(
      :noncurrent_days,
      :storage_class)
      include Aws::Structure
    end

    # Container for specifying the notification configuration of the bucket.
    # If this element is empty, notifications are turned off on the bucket.
    #
    # @note When making an API call, you may pass NotificationConfiguration
    #   data as a hash:
    #
    #       {
    #         topic_configurations: [
    #           {
    #             id: "NotificationId",
    #             topic_arn: "TopicArn", # required
    #             events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             filter: {
    #               key: {
    #                 filter_rules: [
    #                   {
    #                     name: "prefix", # accepts prefix, suffix
    #                     value: "FilterRuleValue",
    #                   },
    #                 ],
    #               },
    #             },
    #           },
    #         ],
    #         queue_configurations: [
    #           {
    #             id: "NotificationId",
    #             queue_arn: "QueueArn", # required
    #             events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             filter: {
    #               key: {
    #                 filter_rules: [
    #                   {
    #                     name: "prefix", # accepts prefix, suffix
    #                     value: "FilterRuleValue",
    #                   },
    #                 ],
    #               },
    #             },
    #           },
    #         ],
    #         lambda_function_configurations: [
    #           {
    #             id: "NotificationId",
    #             lambda_function_arn: "LambdaFunctionArn", # required
    #             events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             filter: {
    #               key: {
    #                 filter_rules: [
    #                   {
    #                     name: "prefix", # accepts prefix, suffix
    #                     value: "FilterRuleValue",
    #                   },
    #                 ],
    #               },
    #             },
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] topic_configurations
    #   @return [Array<Types::TopicConfiguration>]
    #
    # @!attribute [rw] queue_configurations
    #   @return [Array<Types::QueueConfiguration>]
    #
    # @!attribute [rw] lambda_function_configurations
    #   @return [Array<Types::LambdaFunctionConfiguration>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/NotificationConfiguration AWS API Documentation
    #
    class NotificationConfiguration < Struct.new(
      :topic_configurations,
      :queue_configurations,
      :lambda_function_configurations)
      include Aws::Structure
    end

    # @note When making an API call, you may pass NotificationConfigurationDeprecated
    #   data as a hash:
    #
    #       {
    #         topic_configuration: {
    #           id: "NotificationId",
    #           events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           topic: "TopicArn",
    #         },
    #         queue_configuration: {
    #           id: "NotificationId",
    #           event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           queue: "QueueArn",
    #         },
    #         cloud_function_configuration: {
    #           id: "NotificationId",
    #           event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #           cloud_function: "CloudFunction",
    #           invocation_role: "CloudFunctionInvocationRole",
    #         },
    #       }
    #
    # @!attribute [rw] topic_configuration
    #   @return [Types::TopicConfigurationDeprecated]
    #
    # @!attribute [rw] queue_configuration
    #   @return [Types::QueueConfigurationDeprecated]
    #
    # @!attribute [rw] cloud_function_configuration
    #   @return [Types::CloudFunctionConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/NotificationConfigurationDeprecated AWS API Documentation
    #
    class NotificationConfigurationDeprecated < Struct.new(
      :topic_configuration,
      :queue_configuration,
      :cloud_function_configuration)
      include Aws::Structure
    end

    # Container for object key name filtering rules. For information about
    # key name filtering, go to [Configuring Event Notifications][1] in the
    # Amazon Simple Storage Service Developer Guide.
    #
    #
    #
    # [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
    #
    # @note When making an API call, you may pass NotificationConfigurationFilter
    #   data as a hash:
    #
    #       {
    #         key: {
    #           filter_rules: [
    #             {
    #               name: "prefix", # accepts prefix, suffix
    #               value: "FilterRuleValue",
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] key
    #   Container for object key name prefix and suffix filtering rules.
    #   @return [Types::S3KeyFilter]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/NotificationConfigurationFilter AWS API Documentation
    #
    class NotificationConfigurationFilter < Struct.new(
      :key)
      include Aws::Structure
    end

    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] last_modified
    #   @return [Time]
    #
    # @!attribute [rw] etag
    #   @return [String]
    #
    # @!attribute [rw] size
    #   @return [Integer]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Object AWS API Documentation
    #
    class Object < Struct.new(
      :key,
      :last_modified,
      :etag,
      :size,
      :storage_class,
      :owner)
      include Aws::Structure
    end

    # @note When making an API call, you may pass ObjectIdentifier
    #   data as a hash:
    #
    #       {
    #         key: "ObjectKey", # required
    #         version_id: "ObjectVersionId",
    #       }
    #
    # @!attribute [rw] key
    #   Key name of the object to delete.
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   VersionId for the specific version of the object to delete.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ObjectIdentifier AWS API Documentation
    #
    class ObjectIdentifier < Struct.new(
      :key,
      :version_id)
      include Aws::Structure
    end

    # @!attribute [rw] etag
    #   @return [String]
    #
    # @!attribute [rw] size
    #   Size in bytes of the object.
    #   @return [Integer]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   The object key.
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   Version ID of an object.
    #   @return [String]
    #
    # @!attribute [rw] is_latest
    #   Specifies whether the object is (true) or is not (false) the latest
    #   version of an object.
    #   @return [Boolean]
    #
    # @!attribute [rw] last_modified
    #   Date and time the object was last modified.
    #   @return [Time]
    #
    # @!attribute [rw] owner
    #   @return [Types::Owner]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ObjectVersion AWS API Documentation
    #
    class ObjectVersion < Struct.new(
      :etag,
      :size,
      :storage_class,
      :key,
      :version_id,
      :is_latest,
      :last_modified,
      :owner)
      include Aws::Structure
    end

    # Describes the location where the restore job's output is stored.
    #
    # @note When making an API call, you may pass OutputLocation
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] s3
    #   Describes an S3 location that will receive the results of the
    #   restore request.
    #   @return [Types::S3Location]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/OutputLocation AWS API Documentation
    #
    class OutputLocation < Struct.new(
      :s3)
      include Aws::Structure
    end

    # Describes how results of the Select job are serialized.
    #
    # @note When making an API call, you may pass OutputSerialization
    #   data as a hash:
    #
    #       {
    #         csv: {
    #           quote_fields: "ALWAYS", # accepts ALWAYS, ASNEEDED
    #           quote_escape_character: "QuoteEscapeCharacter",
    #           record_delimiter: "RecordDelimiter",
    #           field_delimiter: "FieldDelimiter",
    #           quote_character: "QuoteCharacter",
    #         },
    #         json: {
    #           record_delimiter: "RecordDelimiter",
    #         },
    #       }
    #
    # @!attribute [rw] csv
    #   Describes the serialization of CSV-encoded Select results.
    #   @return [Types::CSVOutput]
    #
    # @!attribute [rw] json
    #   Specifies JSON as request's output serialization format.
    #   @return [Types::JSONOutput]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/OutputSerialization AWS API Documentation
    #
    class OutputSerialization < Struct.new(
      :csv,
      :json)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Owner
    #   data as a hash:
    #
    #       {
    #         display_name: "DisplayName",
    #         id: "ID",
    #       }
    #
    # @!attribute [rw] display_name
    #   @return [String]
    #
    # @!attribute [rw] id
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Owner AWS API Documentation
    #
    class Owner < Struct.new(
      :display_name,
      :id)
      include Aws::Structure
    end

    # @!attribute [rw] part_number
    #   Part number identifying the part. This is a positive integer between
    #   1 and 10,000.
    #   @return [Integer]
    #
    # @!attribute [rw] last_modified
    #   Date and time at which the part was uploaded.
    #   @return [Time]
    #
    # @!attribute [rw] etag
    #   Entity tag returned when the part was uploaded.
    #   @return [String]
    #
    # @!attribute [rw] size
    #   Size of the uploaded part data.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Part AWS API Documentation
    #
    class Part < Struct.new(
      :part_number,
      :last_modified,
      :etag,
      :size)
      include Aws::Structure
    end

    # @!attribute [rw] bytes_scanned
    #   Current number of object bytes scanned.
    #   @return [Integer]
    #
    # @!attribute [rw] bytes_processed
    #   Current number of uncompressed object bytes processed.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Progress AWS API Documentation
    #
    class Progress < Struct.new(
      :bytes_scanned,
      :bytes_processed)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketAccelerateConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         accelerate_configuration: { # required
    #           status: "Enabled", # accepts Enabled, Suspended
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   Name of the bucket for which the accelerate configuration is set.
    #   @return [String]
    #
    # @!attribute [rw] accelerate_configuration
    #   Specifies the Accelerate Configuration you want to set for the
    #   bucket.
    #   @return [Types::AccelerateConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketAccelerateConfigurationRequest AWS API Documentation
    #
    class PutBucketAccelerateConfigurationRequest < Struct.new(
      :bucket,
      :accelerate_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketAclRequest
    #   data as a hash:
    #
    #       {
    #         acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #         access_control_policy: {
    #           grants: [
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
    #           owner: {
    #             display_name: "DisplayName",
    #             id: "ID",
    #           },
    #         },
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         grant_full_control: "GrantFullControl",
    #         grant_read: "GrantRead",
    #         grant_read_acp: "GrantReadACP",
    #         grant_write: "GrantWrite",
    #         grant_write_acp: "GrantWriteACP",
    #       }
    #
    # @!attribute [rw] acl
    #   The canned ACL to apply to the bucket.
    #   @return [String]
    #
    # @!attribute [rw] access_control_policy
    #   @return [Types::AccessControlPolicy]
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions
    #   on the bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_read
    #   Allows grantee to list the objects in the bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_read_acp
    #   Allows grantee to read the bucket ACL.
    #   @return [String]
    #
    # @!attribute [rw] grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketAclRequest AWS API Documentation
    #
    class PutBucketAclRequest < Struct.new(
      :acl,
      :access_control_policy,
      :bucket,
      :content_md5,
      :grant_full_control,
      :grant_read,
      :grant_read_acp,
      :grant_write,
      :grant_write_acp)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketAnalyticsConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "AnalyticsId", # required
    #         analytics_configuration: { # required
    #           id: "AnalyticsId", # required
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
    #           storage_class_analysis: { # required
    #             data_export: {
    #               output_schema_version: "V_1", # required, accepts V_1
    #               destination: { # required
    #                 s3_bucket_destination: { # required
    #                   format: "CSV", # required, accepts CSV
    #                   bucket_account_id: "AccountId",
    #                   bucket: "BucketName", # required
    #                   prefix: "Prefix",
    #                 },
    #               },
    #             },
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket to which an analytics configuration is
    #   stored.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The identifier used to represent an analytics configuration.
    #   @return [String]
    #
    # @!attribute [rw] analytics_configuration
    #   The configuration and any analyses for the analytics filter.
    #   @return [Types::AnalyticsConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketAnalyticsConfigurationRequest AWS API Documentation
    #
    class PutBucketAnalyticsConfigurationRequest < Struct.new(
      :bucket,
      :id,
      :analytics_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketCorsRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         cors_configuration: { # required
    #           cors_rules: [ # required
    #             {
    #               allowed_headers: ["AllowedHeader"],
    #               allowed_methods: ["AllowedMethod"], # required
    #               allowed_origins: ["AllowedOrigin"], # required
    #               expose_headers: ["ExposeHeader"],
    #               max_age_seconds: 1,
    #             },
    #           ],
    #         },
    #         content_md5: "ContentMD5",
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] cors_configuration
    #   @return [Types::CORSConfiguration]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketCorsRequest AWS API Documentation
    #
    class PutBucketCorsRequest < Struct.new(
      :bucket,
      :cors_configuration,
      :content_md5)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketEncryptionRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         server_side_encryption_configuration: { # required
    #           rules: [ # required
    #             {
    #               apply_server_side_encryption_by_default: {
    #                 sse_algorithm: "AES256", # required, accepts AES256, aws:kms
    #                 kms_master_key_id: "SSEKMSKeyId",
    #               },
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket for which the server-side encryption
    #   configuration is set.
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   The base64-encoded 128-bit MD5 digest of the server-side encryption
    #   configuration.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption_configuration
    #   Container for server-side encryption configuration rules. Currently
    #   S3 supports one rule only.
    #   @return [Types::ServerSideEncryptionConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketEncryptionRequest AWS API Documentation
    #
    class PutBucketEncryptionRequest < Struct.new(
      :bucket,
      :content_md5,
      :server_side_encryption_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketInventoryConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "InventoryId", # required
    #         inventory_configuration: { # required
    #           destination: { # required
    #             s3_bucket_destination: { # required
    #               account_id: "AccountId",
    #               bucket: "BucketName", # required
    #               format: "CSV", # required, accepts CSV, ORC
    #               prefix: "Prefix",
    #               encryption: {
    #                 sses3: {
    #                 },
    #                 ssekms: {
    #                   key_id: "SSEKMSKeyId", # required
    #                 },
    #               },
    #             },
    #           },
    #           is_enabled: false, # required
    #           filter: {
    #             prefix: "Prefix", # required
    #           },
    #           id: "InventoryId", # required
    #           included_object_versions: "All", # required, accepts All, Current
    #           optional_fields: ["Size"], # accepts Size, LastModifiedDate, StorageClass, ETag, IsMultipartUploaded, ReplicationStatus, EncryptionStatus
    #           schedule: { # required
    #             frequency: "Daily", # required, accepts Daily, Weekly
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket where the inventory configuration will be
    #   stored.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The ID used to identify the inventory configuration.
    #   @return [String]
    #
    # @!attribute [rw] inventory_configuration
    #   Specifies the inventory configuration.
    #   @return [Types::InventoryConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketInventoryConfigurationRequest AWS API Documentation
    #
    class PutBucketInventoryConfigurationRequest < Struct.new(
      :bucket,
      :id,
      :inventory_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketLifecycleConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         lifecycle_configuration: {
    #           rules: [ # required
    #             {
    #               expiration: {
    #                 date: Time.now,
    #                 days: 1,
    #                 expired_object_delete_marker: false,
    #               },
    #               id: "ID",
    #               prefix: "Prefix",
    #               filter: {
    #                 prefix: "Prefix",
    #                 tag: {
    #                   key: "ObjectKey", # required
    #                   value: "Value", # required
    #                 },
    #                 and: {
    #                   prefix: "Prefix",
    #                   tags: [
    #                     {
    #                       key: "ObjectKey", # required
    #                       value: "Value", # required
    #                     },
    #                   ],
    #                 },
    #               },
    #               status: "Enabled", # required, accepts Enabled, Disabled
    #               transitions: [
    #                 {
    #                   date: Time.now,
    #                   days: 1,
    #                   storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #                 },
    #               ],
    #               noncurrent_version_transitions: [
    #                 {
    #                   noncurrent_days: 1,
    #                   storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #                 },
    #               ],
    #               noncurrent_version_expiration: {
    #                 noncurrent_days: 1,
    #               },
    #               abort_incomplete_multipart_upload: {
    #                 days_after_initiation: 1,
    #               },
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] lifecycle_configuration
    #   @return [Types::BucketLifecycleConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketLifecycleConfigurationRequest AWS API Documentation
    #
    class PutBucketLifecycleConfigurationRequest < Struct.new(
      :bucket,
      :lifecycle_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketLifecycleRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         lifecycle_configuration: {
    #           rules: [ # required
    #             {
    #               expiration: {
    #                 date: Time.now,
    #                 days: 1,
    #                 expired_object_delete_marker: false,
    #               },
    #               id: "ID",
    #               prefix: "Prefix", # required
    #               status: "Enabled", # required, accepts Enabled, Disabled
    #               transition: {
    #                 date: Time.now,
    #                 days: 1,
    #                 storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #               },
    #               noncurrent_version_transition: {
    #                 noncurrent_days: 1,
    #                 storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #               },
    #               noncurrent_version_expiration: {
    #                 noncurrent_days: 1,
    #               },
    #               abort_incomplete_multipart_upload: {
    #                 days_after_initiation: 1,
    #               },
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] lifecycle_configuration
    #   @return [Types::LifecycleConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketLifecycleRequest AWS API Documentation
    #
    class PutBucketLifecycleRequest < Struct.new(
      :bucket,
      :content_md5,
      :lifecycle_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketLoggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         bucket_logging_status: { # required
    #           logging_enabled: {
    #             target_bucket: "TargetBucket", # required
    #             target_grants: [
    #               {
    #                 grantee: {
    #                   display_name: "DisplayName",
    #                   email_address: "EmailAddress",
    #                   id: "ID",
    #                   type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #                   uri: "URI",
    #                 },
    #                 permission: "FULL_CONTROL", # accepts FULL_CONTROL, READ, WRITE
    #               },
    #             ],
    #             target_prefix: "TargetPrefix", # required
    #           },
    #         },
    #         content_md5: "ContentMD5",
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] bucket_logging_status
    #   @return [Types::BucketLoggingStatus]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketLoggingRequest AWS API Documentation
    #
    class PutBucketLoggingRequest < Struct.new(
      :bucket,
      :bucket_logging_status,
      :content_md5)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketMetricsConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         id: "MetricsId", # required
    #         metrics_configuration: { # required
    #           id: "MetricsId", # required
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
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   The name of the bucket for which the metrics configuration is set.
    #   @return [String]
    #
    # @!attribute [rw] id
    #   The ID used to identify the metrics configuration.
    #   @return [String]
    #
    # @!attribute [rw] metrics_configuration
    #   Specifies the metrics configuration.
    #   @return [Types::MetricsConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketMetricsConfigurationRequest AWS API Documentation
    #
    class PutBucketMetricsConfigurationRequest < Struct.new(
      :bucket,
      :id,
      :metrics_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketNotificationConfigurationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         notification_configuration: { # required
    #           topic_configurations: [
    #             {
    #               id: "NotificationId",
    #               topic_arn: "TopicArn", # required
    #               events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #               filter: {
    #                 key: {
    #                   filter_rules: [
    #                     {
    #                       name: "prefix", # accepts prefix, suffix
    #                       value: "FilterRuleValue",
    #                     },
    #                   ],
    #                 },
    #               },
    #             },
    #           ],
    #           queue_configurations: [
    #             {
    #               id: "NotificationId",
    #               queue_arn: "QueueArn", # required
    #               events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #               filter: {
    #                 key: {
    #                   filter_rules: [
    #                     {
    #                       name: "prefix", # accepts prefix, suffix
    #                       value: "FilterRuleValue",
    #                     },
    #                   ],
    #                 },
    #               },
    #             },
    #           ],
    #           lambda_function_configurations: [
    #             {
    #               id: "NotificationId",
    #               lambda_function_arn: "LambdaFunctionArn", # required
    #               events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #               filter: {
    #                 key: {
    #                   filter_rules: [
    #                     {
    #                       name: "prefix", # accepts prefix, suffix
    #                       value: "FilterRuleValue",
    #                     },
    #                   ],
    #                 },
    #               },
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] notification_configuration
    #   Container for specifying the notification configuration of the
    #   bucket. If this element is empty, notifications are turned off on
    #   the bucket.
    #   @return [Types::NotificationConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketNotificationConfigurationRequest AWS API Documentation
    #
    class PutBucketNotificationConfigurationRequest < Struct.new(
      :bucket,
      :notification_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketNotificationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         notification_configuration: { # required
    #           topic_configuration: {
    #             id: "NotificationId",
    #             events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             topic: "TopicArn",
    #           },
    #           queue_configuration: {
    #             id: "NotificationId",
    #             event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             queue: "QueueArn",
    #           },
    #           cloud_function_configuration: {
    #             id: "NotificationId",
    #             event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #             cloud_function: "CloudFunction",
    #             invocation_role: "CloudFunctionInvocationRole",
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] notification_configuration
    #   @return [Types::NotificationConfigurationDeprecated]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketNotificationRequest AWS API Documentation
    #
    class PutBucketNotificationRequest < Struct.new(
      :bucket,
      :content_md5,
      :notification_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketPolicyRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         confirm_remove_self_bucket_access: false,
    #         policy: "Policy", # required
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] confirm_remove_self_bucket_access
    #   Set this parameter to true to confirm that you want to remove your
    #   permissions to change this bucket policy in the future.
    #   @return [Boolean]
    #
    # @!attribute [rw] policy
    #   The bucket policy as a JSON document.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketPolicyRequest AWS API Documentation
    #
    class PutBucketPolicyRequest < Struct.new(
      :bucket,
      :content_md5,
      :confirm_remove_self_bucket_access,
      :policy)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketReplicationRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         replication_configuration: { # required
    #           role: "Role", # required
    #           rules: [ # required
    #             {
    #               id: "ID",
    #               prefix: "Prefix", # required
    #               status: "Enabled", # required, accepts Enabled, Disabled
    #               source_selection_criteria: {
    #                 sse_kms_encrypted_objects: {
    #                   status: "Enabled", # required, accepts Enabled, Disabled
    #                 },
    #               },
    #               destination: { # required
    #                 bucket: "BucketName", # required
    #                 account: "AccountId",
    #                 storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #                 access_control_translation: {
    #                   owner: "Destination", # required, accepts Destination
    #                 },
    #                 encryption_configuration: {
    #                   replica_kms_key_id: "ReplicaKmsKeyID",
    #                 },
    #               },
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] replication_configuration
    #   Container for replication rules. You can add as many as 1,000 rules.
    #   Total replication configuration size can be up to 2 MB.
    #   @return [Types::ReplicationConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketReplicationRequest AWS API Documentation
    #
    class PutBucketReplicationRequest < Struct.new(
      :bucket,
      :content_md5,
      :replication_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketRequestPaymentRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         request_payment_configuration: { # required
    #           payer: "Requester", # required, accepts Requester, BucketOwner
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] request_payment_configuration
    #   @return [Types::RequestPaymentConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketRequestPaymentRequest AWS API Documentation
    #
    class PutBucketRequestPaymentRequest < Struct.new(
      :bucket,
      :content_md5,
      :request_payment_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketTaggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         tagging: { # required
    #           tag_set: [ # required
    #             {
    #               key: "ObjectKey", # required
    #               value: "Value", # required
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] tagging
    #   @return [Types::Tagging]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketTaggingRequest AWS API Documentation
    #
    class PutBucketTaggingRequest < Struct.new(
      :bucket,
      :content_md5,
      :tagging)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketVersioningRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         mfa: "MFA",
    #         versioning_configuration: { # required
    #           mfa_delete: "Enabled", # accepts Enabled, Disabled
    #           status: "Enabled", # accepts Enabled, Suspended
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] mfa
    #   The concatenation of the authentication device's serial number, a
    #   space, and the value that is displayed on your authentication
    #   device.
    #   @return [String]
    #
    # @!attribute [rw] versioning_configuration
    #   @return [Types::VersioningConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketVersioningRequest AWS API Documentation
    #
    class PutBucketVersioningRequest < Struct.new(
      :bucket,
      :content_md5,
      :mfa,
      :versioning_configuration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutBucketWebsiteRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         website_configuration: { # required
    #           error_document: {
    #             key: "ObjectKey", # required
    #           },
    #           index_document: {
    #             suffix: "Suffix", # required
    #           },
    #           redirect_all_requests_to: {
    #             host_name: "HostName", # required
    #             protocol: "http", # accepts http, https
    #           },
    #           routing_rules: [
    #             {
    #               condition: {
    #                 http_error_code_returned_equals: "HttpErrorCodeReturnedEquals",
    #                 key_prefix_equals: "KeyPrefixEquals",
    #               },
    #               redirect: { # required
    #                 host_name: "HostName",
    #                 http_redirect_code: "HttpRedirectCode",
    #                 protocol: "http", # accepts http, https
    #                 replace_key_prefix_with: "ReplaceKeyPrefixWith",
    #                 replace_key_with: "ReplaceKeyWith",
    #               },
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] website_configuration
    #   @return [Types::WebsiteConfiguration]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutBucketWebsiteRequest AWS API Documentation
    #
    class PutBucketWebsiteRequest < Struct.new(
      :bucket,
      :content_md5,
      :website_configuration)
      include Aws::Structure
    end

    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectAclOutput AWS API Documentation
    #
    class PutObjectAclOutput < Struct.new(
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutObjectAclRequest
    #   data as a hash:
    #
    #       {
    #         acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #         access_control_policy: {
    #           grants: [
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
    #           owner: {
    #             display_name: "DisplayName",
    #             id: "ID",
    #           },
    #         },
    #         bucket: "BucketName", # required
    #         content_md5: "ContentMD5",
    #         grant_full_control: "GrantFullControl",
    #         grant_read: "GrantRead",
    #         grant_read_acp: "GrantReadACP",
    #         grant_write: "GrantWrite",
    #         grant_write_acp: "GrantWriteACP",
    #         key: "ObjectKey", # required
    #         request_payer: "requester", # accepts requester
    #         version_id: "ObjectVersionId",
    #       }
    #
    # @!attribute [rw] acl
    #   The canned ACL to apply to the object.
    #   @return [String]
    #
    # @!attribute [rw] access_control_policy
    #   @return [Types::AccessControlPolicy]
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions
    #   on the bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_read
    #   Allows grantee to list the objects in the bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_read_acp
    #   Allows grantee to read the bucket ACL.
    #   @return [String]
    #
    # @!attribute [rw] grant_write
    #   Allows grantee to create, overwrite, and delete any object in the
    #   bucket.
    #   @return [String]
    #
    # @!attribute [rw] grant_write_acp
    #   Allows grantee to write the ACL for the applicable bucket.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   VersionId used to reference a specific version of the object.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectAclRequest AWS API Documentation
    #
    class PutObjectAclRequest < Struct.new(
      :acl,
      :access_control_policy,
      :bucket,
      :content_md5,
      :grant_full_control,
      :grant_read,
      :grant_read_acp,
      :grant_write,
      :grant_write_acp,
      :key,
      :request_payer,
      :version_id)
      include Aws::Structure
    end

    # @!attribute [rw] expiration
    #   If the object expiration is configured, this will contain the
    #   expiration date (expiry-date) and rule ID (rule-id). The value of
    #   rule-id is URL encoded.
    #   @return [String]
    #
    # @!attribute [rw] etag
    #   Entity tag for the uploaded object.
    #   @return [String]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   Version of the object.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectOutput AWS API Documentation
    #
    class PutObjectOutput < Struct.new(
      :expiration,
      :etag,
      :server_side_encryption,
      :version_id,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutObjectRequest
    #   data as a hash:
    #
    #       {
    #         acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #         body: source_file,
    #         bucket: "BucketName", # required
    #         cache_control: "CacheControl",
    #         content_disposition: "ContentDisposition",
    #         content_encoding: "ContentEncoding",
    #         content_language: "ContentLanguage",
    #         content_length: 1,
    #         content_md5: "ContentMD5",
    #         content_type: "ContentType",
    #         expires: Time.now,
    #         grant_full_control: "GrantFullControl",
    #         grant_read: "GrantRead",
    #         grant_read_acp: "GrantReadACP",
    #         grant_write_acp: "GrantWriteACP",
    #         key: "ObjectKey", # required
    #         metadata: {
    #           "MetadataKey" => "MetadataValue",
    #         },
    #         server_side_encryption: "AES256", # accepts AES256, aws:kms
    #         storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #         website_redirect_location: "WebsiteRedirectLocation",
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         ssekms_key_id: "SSEKMSKeyId",
    #         request_payer: "requester", # accepts requester
    #         tagging: "TaggingHeader",
    #       }
    #
    # @!attribute [rw] acl
    #   The canned ACL to apply to the object.
    #   @return [String]
    #
    # @!attribute [rw] body
    #   Object data.
    #   @return [IO]
    #
    # @!attribute [rw] bucket
    #   Name of the bucket to which the PUT operation was initiated.
    #   @return [String]
    #
    # @!attribute [rw] cache_control
    #   Specifies caching behavior along the request/reply chain.
    #   @return [String]
    #
    # @!attribute [rw] content_disposition
    #   Specifies presentational information for the object.
    #   @return [String]
    #
    # @!attribute [rw] content_encoding
    #   Specifies what content encodings have been applied to the object and
    #   thus what decoding mechanisms must be applied to obtain the
    #   media-type referenced by the Content-Type header field.
    #   @return [String]
    #
    # @!attribute [rw] content_language
    #   The language the content is in.
    #   @return [String]
    #
    # @!attribute [rw] content_length
    #   Size of the body in bytes. This parameter is useful when the size of
    #   the body cannot be determined automatically.
    #   @return [Integer]
    #
    # @!attribute [rw] content_md5
    #   The base64-encoded 128-bit MD5 digest of the part data.
    #   @return [String]
    #
    # @!attribute [rw] content_type
    #   A standard MIME type describing the format of the object data.
    #   @return [String]
    #
    # @!attribute [rw] expires
    #   The date and time at which the object is no longer cacheable.
    #   @return [Time]
    #
    # @!attribute [rw] grant_full_control
    #   Gives the grantee READ, READ\_ACP, and WRITE\_ACP permissions on the
    #   object.
    #   @return [String]
    #
    # @!attribute [rw] grant_read
    #   Allows grantee to read the object data and its metadata.
    #   @return [String]
    #
    # @!attribute [rw] grant_read_acp
    #   Allows grantee to read the object ACL.
    #   @return [String]
    #
    # @!attribute [rw] grant_write_acp
    #   Allows grantee to write the ACL for the applicable object.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   Object key for which the PUT operation was initiated.
    #   @return [String]
    #
    # @!attribute [rw] metadata
    #   A map of metadata to store with the object in S3.
    #   @return [Hash<String,String>]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] storage_class
    #   The type of storage to use for the object. Defaults to 'STANDARD'.
    #   @return [String]
    #
    # @!attribute [rw] website_redirect_location
    #   If the bucket is configured as a website, redirects requests for
    #   this object to another object in the same bucket or to an external
    #   URL. Amazon S3 stores the value of this header in the object
    #   metadata.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   Specifies the AWS KMS key ID to use for object encryption. All GET
    #   and PUT requests for an object protected by AWS KMS will fail if not
    #   made via SSL or using SigV4. Documentation on configuring any of the
    #   officially supported AWS SDKs and CLI can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @!attribute [rw] tagging
    #   The tag-set for the object. The tag-set must be encoded as URL Query
    #   parameters
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectRequest AWS API Documentation
    #
    class PutObjectRequest < Struct.new(
      :acl,
      :body,
      :bucket,
      :cache_control,
      :content_disposition,
      :content_encoding,
      :content_language,
      :content_length,
      :content_md5,
      :content_type,
      :expires,
      :grant_full_control,
      :grant_read,
      :grant_read_acp,
      :grant_write_acp,
      :key,
      :metadata,
      :server_side_encryption,
      :storage_class,
      :website_redirect_location,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_payer,
      :tagging)
      include Aws::Structure
    end

    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectTaggingOutput AWS API Documentation
    #
    class PutObjectTaggingOutput < Struct.new(
      :version_id)
      include Aws::Structure
    end

    # @note When making an API call, you may pass PutObjectTaggingRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         version_id: "ObjectVersionId",
    #         content_md5: "ContentMD5",
    #         tagging: { # required
    #           tag_set: [ # required
    #             {
    #               key: "ObjectKey", # required
    #               value: "Value", # required
    #             },
    #           ],
    #         },
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @!attribute [rw] content_md5
    #   @return [String]
    #
    # @!attribute [rw] tagging
    #   @return [Types::Tagging]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/PutObjectTaggingRequest AWS API Documentation
    #
    class PutObjectTaggingRequest < Struct.new(
      :bucket,
      :key,
      :version_id,
      :content_md5,
      :tagging)
      include Aws::Structure
    end

    # Container for specifying an configuration when you want Amazon S3 to
    # publish events to an Amazon Simple Queue Service (Amazon SQS) queue.
    #
    # @note When making an API call, you may pass QueueConfiguration
    #   data as a hash:
    #
    #       {
    #         id: "NotificationId",
    #         queue_arn: "QueueArn", # required
    #         events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         filter: {
    #           key: {
    #             filter_rules: [
    #               {
    #                 name: "prefix", # accepts prefix, suffix
    #                 value: "FilterRuleValue",
    #               },
    #             ],
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] id
    #   Optional unique identifier for configurations in a notification
    #   configuration. If you don't provide one, Amazon S3 will assign an
    #   ID.
    #   @return [String]
    #
    # @!attribute [rw] queue_arn
    #   Amazon SQS queue ARN to which Amazon S3 will publish a message when
    #   it detects events of specified type.
    #   @return [String]
    #
    # @!attribute [rw] events
    #   @return [Array<String>]
    #
    # @!attribute [rw] filter
    #   Container for object key name filtering rules. For information about
    #   key name filtering, go to [Configuring Event Notifications][1] in
    #   the Amazon Simple Storage Service Developer Guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
    #   @return [Types::NotificationConfigurationFilter]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/QueueConfiguration AWS API Documentation
    #
    class QueueConfiguration < Struct.new(
      :id,
      :queue_arn,
      :events,
      :filter)
      include Aws::Structure
    end

    # @note When making an API call, you may pass QueueConfigurationDeprecated
    #   data as a hash:
    #
    #       {
    #         id: "NotificationId",
    #         event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         queue: "QueueArn",
    #       }
    #
    # @!attribute [rw] id
    #   Optional unique identifier for configurations in a notification
    #   configuration. If you don't provide one, Amazon S3 will assign an
    #   ID.
    #   @return [String]
    #
    # @!attribute [rw] event
    #   Bucket event for which to send notifications.
    #   @return [String]
    #
    # @!attribute [rw] events
    #   @return [Array<String>]
    #
    # @!attribute [rw] queue
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/QueueConfigurationDeprecated AWS API Documentation
    #
    class QueueConfigurationDeprecated < Struct.new(
      :id,
      :event,
      :events,
      :queue)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Redirect
    #   data as a hash:
    #
    #       {
    #         host_name: "HostName",
    #         http_redirect_code: "HttpRedirectCode",
    #         protocol: "http", # accepts http, https
    #         replace_key_prefix_with: "ReplaceKeyPrefixWith",
    #         replace_key_with: "ReplaceKeyWith",
    #       }
    #
    # @!attribute [rw] host_name
    #   The host name to use in the redirect request.
    #   @return [String]
    #
    # @!attribute [rw] http_redirect_code
    #   The HTTP redirect code to use on the response. Not required if one
    #   of the siblings is present.
    #   @return [String]
    #
    # @!attribute [rw] protocol
    #   Protocol to use (http, https) when redirecting requests. The default
    #   is the protocol that is used in the original request.
    #   @return [String]
    #
    # @!attribute [rw] replace_key_prefix_with
    #   The object key prefix to use in the redirect request. For example,
    #   to redirect requests for all pages with prefix docs/ (objects in the
    #   docs/ folder) to documents/, you can set a condition block with
    #   KeyPrefixEquals set to docs/ and in the Redirect set
    #   ReplaceKeyPrefixWith to /documents. Not required if one of the
    #   siblings is present. Can be present only if ReplaceKeyWith is not
    #   provided.
    #   @return [String]
    #
    # @!attribute [rw] replace_key_with
    #   The specific object key to use in the redirect request. For example,
    #   redirect request to error.html. Not required if one of the sibling
    #   is present. Can be present only if ReplaceKeyPrefixWith is not
    #   provided.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Redirect AWS API Documentation
    #
    class Redirect < Struct.new(
      :host_name,
      :http_redirect_code,
      :protocol,
      :replace_key_prefix_with,
      :replace_key_with)
      include Aws::Structure
    end

    # @note When making an API call, you may pass RedirectAllRequestsTo
    #   data as a hash:
    #
    #       {
    #         host_name: "HostName", # required
    #         protocol: "http", # accepts http, https
    #       }
    #
    # @!attribute [rw] host_name
    #   Name of the host where requests will be redirected.
    #   @return [String]
    #
    # @!attribute [rw] protocol
    #   Protocol to use (http, https) when redirecting requests. The default
    #   is the protocol that is used in the original request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RedirectAllRequestsTo AWS API Documentation
    #
    class RedirectAllRequestsTo < Struct.new(
      :host_name,
      :protocol)
      include Aws::Structure
    end

    # Container for replication rules. You can add as many as 1,000 rules.
    # Total replication configuration size can be up to 2 MB.
    #
    # @note When making an API call, you may pass ReplicationConfiguration
    #   data as a hash:
    #
    #       {
    #         role: "Role", # required
    #         rules: [ # required
    #           {
    #             id: "ID",
    #             prefix: "Prefix", # required
    #             status: "Enabled", # required, accepts Enabled, Disabled
    #             source_selection_criteria: {
    #               sse_kms_encrypted_objects: {
    #                 status: "Enabled", # required, accepts Enabled, Disabled
    #               },
    #             },
    #             destination: { # required
    #               bucket: "BucketName", # required
    #               account: "AccountId",
    #               storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #               access_control_translation: {
    #                 owner: "Destination", # required, accepts Destination
    #               },
    #               encryption_configuration: {
    #                 replica_kms_key_id: "ReplicaKmsKeyID",
    #               },
    #             },
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] role
    #   Amazon Resource Name (ARN) of an IAM role for Amazon S3 to assume
    #   when replicating the objects.
    #   @return [String]
    #
    # @!attribute [rw] rules
    #   Container for information about a particular replication rule.
    #   Replication configuration must have at least one rule and can
    #   contain up to 1,000 rules.
    #   @return [Array<Types::ReplicationRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ReplicationConfiguration AWS API Documentation
    #
    class ReplicationConfiguration < Struct.new(
      :role,
      :rules)
      include Aws::Structure
    end

    # Container for information about a particular replication rule.
    #
    # @note When making an API call, you may pass ReplicationRule
    #   data as a hash:
    #
    #       {
    #         id: "ID",
    #         prefix: "Prefix", # required
    #         status: "Enabled", # required, accepts Enabled, Disabled
    #         source_selection_criteria: {
    #           sse_kms_encrypted_objects: {
    #             status: "Enabled", # required, accepts Enabled, Disabled
    #           },
    #         },
    #         destination: { # required
    #           bucket: "BucketName", # required
    #           account: "AccountId",
    #           storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #           access_control_translation: {
    #             owner: "Destination", # required, accepts Destination
    #           },
    #           encryption_configuration: {
    #             replica_kms_key_id: "ReplicaKmsKeyID",
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] id
    #   Unique identifier for the rule. The value cannot be longer than 255
    #   characters.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   Object keyname prefix identifying one or more objects to which the
    #   rule applies. Maximum prefix length can be up to 1,024 characters.
    #   Overlapping prefixes are not supported.
    #   @return [String]
    #
    # @!attribute [rw] status
    #   The rule is ignored if status is not Enabled.
    #   @return [String]
    #
    # @!attribute [rw] source_selection_criteria
    #   Container for filters that define which source objects should be
    #   replicated.
    #   @return [Types::SourceSelectionCriteria]
    #
    # @!attribute [rw] destination
    #   Container for replication destination information.
    #   @return [Types::Destination]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ReplicationRule AWS API Documentation
    #
    class ReplicationRule < Struct.new(
      :id,
      :prefix,
      :status,
      :source_selection_criteria,
      :destination)
      include Aws::Structure
    end

    # @note When making an API call, you may pass RequestPaymentConfiguration
    #   data as a hash:
    #
    #       {
    #         payer: "Requester", # required, accepts Requester, BucketOwner
    #       }
    #
    # @!attribute [rw] payer
    #   Specifies who pays for the download and request fees.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RequestPaymentConfiguration AWS API Documentation
    #
    class RequestPaymentConfiguration < Struct.new(
      :payer)
      include Aws::Structure
    end

    # @!attribute [rw] enabled
    #   Specifies whether periodic QueryProgress frames should be sent.
    #   Valid values: TRUE, FALSE. Default value: FALSE.
    #   @return [Boolean]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RequestProgress AWS API Documentation
    #
    class RequestProgress < Struct.new(
      :enabled)
      include Aws::Structure
    end

    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @!attribute [rw] restore_output_path
    #   Indicates the path in the provided S3 output location where Select
    #   results will be restored to.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RestoreObjectOutput AWS API Documentation
    #
    class RestoreObjectOutput < Struct.new(
      :request_charged,
      :restore_output_path)
      include Aws::Structure
    end

    # @note When making an API call, you may pass RestoreObjectRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         key: "ObjectKey", # required
    #         version_id: "ObjectVersionId",
    #         restore_request: {
    #           days: 1,
    #           glacier_job_parameters: {
    #             tier: "Standard", # required, accepts Standard, Bulk, Expedited
    #           },
    #           type: "SELECT", # accepts SELECT
    #           tier: "Standard", # accepts Standard, Bulk, Expedited
    #           description: "Description",
    #           select_parameters: {
    #             input_serialization: { # required
    #               csv: {
    #                 file_header_info: "USE", # accepts USE, IGNORE, NONE
    #                 comments: "Comments",
    #                 quote_escape_character: "QuoteEscapeCharacter",
    #                 record_delimiter: "RecordDelimiter",
    #                 field_delimiter: "FieldDelimiter",
    #                 quote_character: "QuoteCharacter",
    #               },
    #               compression_type: "NONE", # accepts NONE, GZIP
    #               json: {
    #                 type: "DOCUMENT", # accepts DOCUMENT, LINES
    #               },
    #             },
    #             expression_type: "SQL", # required, accepts SQL
    #             expression: "Expression", # required
    #             output_serialization: { # required
    #               csv: {
    #                 quote_fields: "ALWAYS", # accepts ALWAYS, ASNEEDED
    #                 quote_escape_character: "QuoteEscapeCharacter",
    #                 record_delimiter: "RecordDelimiter",
    #                 field_delimiter: "FieldDelimiter",
    #                 quote_character: "QuoteCharacter",
    #               },
    #               json: {
    #                 record_delimiter: "RecordDelimiter",
    #               },
    #             },
    #           },
    #           output_location: {
    #             s3: {
    #               bucket_name: "BucketName", # required
    #               prefix: "LocationPrefix", # required
    #               encryption: {
    #                 encryption_type: "AES256", # required, accepts AES256, aws:kms
    #                 kms_key_id: "SSEKMSKeyId",
    #                 kms_context: "KMSContext",
    #               },
    #               canned_acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #               access_control_list: [
    #                 {
    #                   grantee: {
    #                     display_name: "DisplayName",
    #                     email_address: "EmailAddress",
    #                     id: "ID",
    #                     type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #                     uri: "URI",
    #                   },
    #                   permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #                 },
    #               ],
    #               tagging: {
    #                 tag_set: [ # required
    #                   {
    #                     key: "ObjectKey", # required
    #                     value: "Value", # required
    #                   },
    #                 ],
    #               },
    #               user_metadata: [
    #                 {
    #                   name: "MetadataKey",
    #                   value: "MetadataValue",
    #                 },
    #               ],
    #               storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #             },
    #           },
    #         },
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] version_id
    #   @return [String]
    #
    # @!attribute [rw] restore_request
    #   Container for restore job parameters.
    #   @return [Types::RestoreRequest]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RestoreObjectRequest AWS API Documentation
    #
    class RestoreObjectRequest < Struct.new(
      :bucket,
      :key,
      :version_id,
      :restore_request,
      :request_payer)
      include Aws::Structure
    end

    # Container for restore job parameters.
    #
    # @note When making an API call, you may pass RestoreRequest
    #   data as a hash:
    #
    #       {
    #         days: 1,
    #         glacier_job_parameters: {
    #           tier: "Standard", # required, accepts Standard, Bulk, Expedited
    #         },
    #         type: "SELECT", # accepts SELECT
    #         tier: "Standard", # accepts Standard, Bulk, Expedited
    #         description: "Description",
    #         select_parameters: {
    #           input_serialization: { # required
    #             csv: {
    #               file_header_info: "USE", # accepts USE, IGNORE, NONE
    #               comments: "Comments",
    #               quote_escape_character: "QuoteEscapeCharacter",
    #               record_delimiter: "RecordDelimiter",
    #               field_delimiter: "FieldDelimiter",
    #               quote_character: "QuoteCharacter",
    #             },
    #             compression_type: "NONE", # accepts NONE, GZIP
    #             json: {
    #               type: "DOCUMENT", # accepts DOCUMENT, LINES
    #             },
    #           },
    #           expression_type: "SQL", # required, accepts SQL
    #           expression: "Expression", # required
    #           output_serialization: { # required
    #             csv: {
    #               quote_fields: "ALWAYS", # accepts ALWAYS, ASNEEDED
    #               quote_escape_character: "QuoteEscapeCharacter",
    #               record_delimiter: "RecordDelimiter",
    #               field_delimiter: "FieldDelimiter",
    #               quote_character: "QuoteCharacter",
    #             },
    #             json: {
    #               record_delimiter: "RecordDelimiter",
    #             },
    #           },
    #         },
    #         output_location: {
    #           s3: {
    #             bucket_name: "BucketName", # required
    #             prefix: "LocationPrefix", # required
    #             encryption: {
    #               encryption_type: "AES256", # required, accepts AES256, aws:kms
    #               kms_key_id: "SSEKMSKeyId",
    #               kms_context: "KMSContext",
    #             },
    #             canned_acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #             access_control_list: [
    #               {
    #                 grantee: {
    #                   display_name: "DisplayName",
    #                   email_address: "EmailAddress",
    #                   id: "ID",
    #                   type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #                   uri: "URI",
    #                 },
    #                 permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #               },
    #             ],
    #             tagging: {
    #               tag_set: [ # required
    #                 {
    #                   key: "ObjectKey", # required
    #                   value: "Value", # required
    #                 },
    #               ],
    #             },
    #             user_metadata: [
    #               {
    #                 name: "MetadataKey",
    #                 value: "MetadataValue",
    #               },
    #             ],
    #             storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] days
    #   Lifetime of the active copy in days. Do not use with restores that
    #   specify OutputLocation.
    #   @return [Integer]
    #
    # @!attribute [rw] glacier_job_parameters
    #   Glacier related parameters pertaining to this job. Do not use with
    #   restores that specify OutputLocation.
    #   @return [Types::GlacierJobParameters]
    #
    # @!attribute [rw] type
    #   Type of restore request.
    #   @return [String]
    #
    # @!attribute [rw] tier
    #   Glacier retrieval tier at which the restore will be processed.
    #   @return [String]
    #
    # @!attribute [rw] description
    #   The optional description for the job.
    #   @return [String]
    #
    # @!attribute [rw] select_parameters
    #   Describes the parameters for Select job types.
    #   @return [Types::SelectParameters]
    #
    # @!attribute [rw] output_location
    #   Describes the location where the restore job's output is stored.
    #   @return [Types::OutputLocation]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RestoreRequest AWS API Documentation
    #
    class RestoreRequest < Struct.new(
      :days,
      :glacier_job_parameters,
      :type,
      :tier,
      :description,
      :select_parameters,
      :output_location)
      include Aws::Structure
    end

    # @note When making an API call, you may pass RoutingRule
    #   data as a hash:
    #
    #       {
    #         condition: {
    #           http_error_code_returned_equals: "HttpErrorCodeReturnedEquals",
    #           key_prefix_equals: "KeyPrefixEquals",
    #         },
    #         redirect: { # required
    #           host_name: "HostName",
    #           http_redirect_code: "HttpRedirectCode",
    #           protocol: "http", # accepts http, https
    #           replace_key_prefix_with: "ReplaceKeyPrefixWith",
    #           replace_key_with: "ReplaceKeyWith",
    #         },
    #       }
    #
    # @!attribute [rw] condition
    #   A container for describing a condition that must be met for the
    #   specified redirect to apply. For example, 1. If request is for pages
    #   in the /docs folder, redirect to the /documents folder. 2. If
    #   request results in HTTP error 4xx, redirect request to another host
    #   where you might process the error.
    #   @return [Types::Condition]
    #
    # @!attribute [rw] redirect
    #   Container for redirect information. You can redirect requests to
    #   another host, to another page, or with another protocol. In the
    #   event of an error, you can can specify a different error code to
    #   return.
    #   @return [Types::Redirect]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/RoutingRule AWS API Documentation
    #
    class RoutingRule < Struct.new(
      :condition,
      :redirect)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Rule
    #   data as a hash:
    #
    #       {
    #         expiration: {
    #           date: Time.now,
    #           days: 1,
    #           expired_object_delete_marker: false,
    #         },
    #         id: "ID",
    #         prefix: "Prefix", # required
    #         status: "Enabled", # required, accepts Enabled, Disabled
    #         transition: {
    #           date: Time.now,
    #           days: 1,
    #           storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #         },
    #         noncurrent_version_transition: {
    #           noncurrent_days: 1,
    #           storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #         },
    #         noncurrent_version_expiration: {
    #           noncurrent_days: 1,
    #         },
    #         abort_incomplete_multipart_upload: {
    #           days_after_initiation: 1,
    #         },
    #       }
    #
    # @!attribute [rw] expiration
    #   @return [Types::LifecycleExpiration]
    #
    # @!attribute [rw] id
    #   Unique identifier for the rule. The value cannot be longer than 255
    #   characters.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   Prefix identifying one or more objects to which the rule applies.
    #   @return [String]
    #
    # @!attribute [rw] status
    #   If 'Enabled', the rule is currently being applied. If
    #   'Disabled', the rule is not currently being applied.
    #   @return [String]
    #
    # @!attribute [rw] transition
    #   @return [Types::Transition]
    #
    # @!attribute [rw] noncurrent_version_transition
    #   Container for the transition rule that describes when noncurrent
    #   objects transition to the STANDARD\_IA, ONEZONE\_IA or GLACIER
    #   storage class. If your bucket is versioning-enabled (or versioning
    #   is suspended), you can set this action to request that Amazon S3
    #   transition noncurrent object versions to the STANDARD\_IA,
    #   ONEZONE\_IA or GLACIER storage class at a specific period in the
    #   object's lifetime.
    #   @return [Types::NoncurrentVersionTransition]
    #
    # @!attribute [rw] noncurrent_version_expiration
    #   Specifies when noncurrent object versions expire. Upon expiration,
    #   Amazon S3 permanently deletes the noncurrent object versions. You
    #   set this lifecycle configuration action on a bucket that has
    #   versioning enabled (or suspended) to request that Amazon S3 delete
    #   noncurrent object versions at a specific period in the object's
    #   lifetime.
    #   @return [Types::NoncurrentVersionExpiration]
    #
    # @!attribute [rw] abort_incomplete_multipart_upload
    #   Specifies the days since the initiation of an Incomplete Multipart
    #   Upload that Lifecycle will wait before permanently removing all
    #   parts of the upload.
    #   @return [Types::AbortIncompleteMultipartUpload]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Rule AWS API Documentation
    #
    class Rule < Struct.new(
      :expiration,
      :id,
      :prefix,
      :status,
      :transition,
      :noncurrent_version_transition,
      :noncurrent_version_expiration,
      :abort_incomplete_multipart_upload)
      include Aws::Structure
    end

    # Container for object key name prefix and suffix filtering rules.
    #
    # @note When making an API call, you may pass S3KeyFilter
    #   data as a hash:
    #
    #       {
    #         filter_rules: [
    #           {
    #             name: "prefix", # accepts prefix, suffix
    #             value: "FilterRuleValue",
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] filter_rules
    #   A list of containers for key value pair that defines the criteria
    #   for the filter rule.
    #   @return [Array<Types::FilterRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/S3KeyFilter AWS API Documentation
    #
    class S3KeyFilter < Struct.new(
      :filter_rules)
      include Aws::Structure
    end

    # Describes an S3 location that will receive the results of the restore
    # request.
    #
    # @note When making an API call, you may pass S3Location
    #   data as a hash:
    #
    #       {
    #         bucket_name: "BucketName", # required
    #         prefix: "LocationPrefix", # required
    #         encryption: {
    #           encryption_type: "AES256", # required, accepts AES256, aws:kms
    #           kms_key_id: "SSEKMSKeyId",
    #           kms_context: "KMSContext",
    #         },
    #         canned_acl: "private", # accepts private, public-read, public-read-write, authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control
    #         access_control_list: [
    #           {
    #             grantee: {
    #               display_name: "DisplayName",
    #               email_address: "EmailAddress",
    #               id: "ID",
    #               type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #               uri: "URI",
    #             },
    #             permission: "FULL_CONTROL", # accepts FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP
    #           },
    #         ],
    #         tagging: {
    #           tag_set: [ # required
    #             {
    #               key: "ObjectKey", # required
    #               value: "Value", # required
    #             },
    #           ],
    #         },
    #         user_metadata: [
    #           {
    #             name: "MetadataKey",
    #             value: "MetadataValue",
    #           },
    #         ],
    #         storage_class: "STANDARD", # accepts STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA
    #       }
    #
    # @!attribute [rw] bucket_name
    #   The name of the bucket where the restore results will be placed.
    #   @return [String]
    #
    # @!attribute [rw] prefix
    #   The prefix that is prepended to the restore results for this
    #   request.
    #   @return [String]
    #
    # @!attribute [rw] encryption
    #   Describes the server-side encryption that will be applied to the
    #   restore results.
    #   @return [Types::Encryption]
    #
    # @!attribute [rw] canned_acl
    #   The canned ACL to apply to the restore results.
    #   @return [String]
    #
    # @!attribute [rw] access_control_list
    #   A list of grants that control access to the staged results.
    #   @return [Array<Types::Grant>]
    #
    # @!attribute [rw] tagging
    #   The tag-set that is applied to the restore results.
    #   @return [Types::Tagging]
    #
    # @!attribute [rw] user_metadata
    #   A list of metadata to store with the restore results in S3.
    #   @return [Array<Types::MetadataEntry>]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the restore results.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/S3Location AWS API Documentation
    #
    class S3Location < Struct.new(
      :bucket_name,
      :prefix,
      :encryption,
      :canned_acl,
      :access_control_list,
      :tagging,
      :user_metadata,
      :storage_class)
      include Aws::Structure
    end

    # Specifies the use of SSE-KMS to encrypt delievered Inventory reports.
    #
    # @note When making an API call, you may pass SSEKMS
    #   data as a hash:
    #
    #       {
    #         key_id: "SSEKMSKeyId", # required
    #       }
    #
    # @!attribute [rw] key_id
    #   Specifies the ID of the AWS Key Management Service (KMS) master
    #   encryption key to use for encrypting Inventory reports.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/SSEKMS AWS API Documentation
    #
    class SSEKMS < Struct.new(
      :key_id)
      include Aws::Structure
    end

    # Specifies the use of SSE-S3 to encrypt delievered Inventory reports.
    #
    # @api private
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/SSES3 AWS API Documentation
    #
    class SSES3 < Aws::EmptyStructure; end

    # Describes the parameters for Select job types.
    #
    # @note When making an API call, you may pass SelectParameters
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] input_serialization
    #   Describes the serialization format of the object.
    #   @return [Types::InputSerialization]
    #
    # @!attribute [rw] expression_type
    #   The type of the provided expression (e.g., SQL).
    #   @return [String]
    #
    # @!attribute [rw] expression
    #   The expression that is used to query the object.
    #   @return [String]
    #
    # @!attribute [rw] output_serialization
    #   Describes how the results of the Select job are serialized.
    #   @return [Types::OutputSerialization]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/SelectParameters AWS API Documentation
    #
    class SelectParameters < Struct.new(
      :input_serialization,
      :expression_type,
      :expression,
      :output_serialization)
      include Aws::Structure
    end

    # Describes the default server-side encryption to apply to new objects
    # in the bucket. If Put Object request does not specify any server-side
    # encryption, this default encryption will be applied.
    #
    # @note When making an API call, you may pass ServerSideEncryptionByDefault
    #   data as a hash:
    #
    #       {
    #         sse_algorithm: "AES256", # required, accepts AES256, aws:kms
    #         kms_master_key_id: "SSEKMSKeyId",
    #       }
    #
    # @!attribute [rw] sse_algorithm
    #   Server-side encryption algorithm to use for the default encryption.
    #   @return [String]
    #
    # @!attribute [rw] kms_master_key_id
    #   KMS master key ID to use for the default encryption. This parameter
    #   is allowed if SSEAlgorithm is aws:kms.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ServerSideEncryptionByDefault AWS API Documentation
    #
    class ServerSideEncryptionByDefault < Struct.new(
      :sse_algorithm,
      :kms_master_key_id)
      include Aws::Structure
    end

    # Container for server-side encryption configuration rules. Currently S3
    # supports one rule only.
    #
    # @note When making an API call, you may pass ServerSideEncryptionConfiguration
    #   data as a hash:
    #
    #       {
    #         rules: [ # required
    #           {
    #             apply_server_side_encryption_by_default: {
    #               sse_algorithm: "AES256", # required, accepts AES256, aws:kms
    #               kms_master_key_id: "SSEKMSKeyId",
    #             },
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] rules
    #   Container for information about a particular server-side encryption
    #   configuration rule.
    #   @return [Array<Types::ServerSideEncryptionRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ServerSideEncryptionConfiguration AWS API Documentation
    #
    class ServerSideEncryptionConfiguration < Struct.new(
      :rules)
      include Aws::Structure
    end

    # Container for information about a particular server-side encryption
    # configuration rule.
    #
    # @note When making an API call, you may pass ServerSideEncryptionRule
    #   data as a hash:
    #
    #       {
    #         apply_server_side_encryption_by_default: {
    #           sse_algorithm: "AES256", # required, accepts AES256, aws:kms
    #           kms_master_key_id: "SSEKMSKeyId",
    #         },
    #       }
    #
    # @!attribute [rw] apply_server_side_encryption_by_default
    #   Describes the default server-side encryption to apply to new objects
    #   in the bucket. If Put Object request does not specify any
    #   server-side encryption, this default encryption will be applied.
    #   @return [Types::ServerSideEncryptionByDefault]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/ServerSideEncryptionRule AWS API Documentation
    #
    class ServerSideEncryptionRule < Struct.new(
      :apply_server_side_encryption_by_default)
      include Aws::Structure
    end

    # Container for filters that define which source objects should be
    # replicated.
    #
    # @note When making an API call, you may pass SourceSelectionCriteria
    #   data as a hash:
    #
    #       {
    #         sse_kms_encrypted_objects: {
    #           status: "Enabled", # required, accepts Enabled, Disabled
    #         },
    #       }
    #
    # @!attribute [rw] sse_kms_encrypted_objects
    #   Container for filter information of selection of KMS Encrypted S3
    #   objects.
    #   @return [Types::SseKmsEncryptedObjects]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/SourceSelectionCriteria AWS API Documentation
    #
    class SourceSelectionCriteria < Struct.new(
      :sse_kms_encrypted_objects)
      include Aws::Structure
    end

    # Container for filter information of selection of KMS Encrypted S3
    # objects.
    #
    # @note When making an API call, you may pass SseKmsEncryptedObjects
    #   data as a hash:
    #
    #       {
    #         status: "Enabled", # required, accepts Enabled, Disabled
    #       }
    #
    # @!attribute [rw] status
    #   The replication for KMS encrypted S3 objects is disabled if status
    #   is not Enabled.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/SseKmsEncryptedObjects AWS API Documentation
    #
    class SseKmsEncryptedObjects < Struct.new(
      :status)
      include Aws::Structure
    end

    # @!attribute [rw] bytes_scanned
    #   Total number of object bytes scanned.
    #   @return [Integer]
    #
    # @!attribute [rw] bytes_processed
    #   Total number of uncompressed object bytes processed.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Stats AWS API Documentation
    #
    class Stats < Struct.new(
      :bytes_scanned,
      :bytes_processed)
      include Aws::Structure
    end

    # @note When making an API call, you may pass StorageClassAnalysis
    #   data as a hash:
    #
    #       {
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
    #       }
    #
    # @!attribute [rw] data_export
    #   A container used to describe how data related to the storage class
    #   analysis should be exported.
    #   @return [Types::StorageClassAnalysisDataExport]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/StorageClassAnalysis AWS API Documentation
    #
    class StorageClassAnalysis < Struct.new(
      :data_export)
      include Aws::Structure
    end

    # @note When making an API call, you may pass StorageClassAnalysisDataExport
    #   data as a hash:
    #
    #       {
    #         output_schema_version: "V_1", # required, accepts V_1
    #         destination: { # required
    #           s3_bucket_destination: { # required
    #             format: "CSV", # required, accepts CSV
    #             bucket_account_id: "AccountId",
    #             bucket: "BucketName", # required
    #             prefix: "Prefix",
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] output_schema_version
    #   The version of the output schema to use when exporting data. Must be
    #   V\_1.
    #   @return [String]
    #
    # @!attribute [rw] destination
    #   The place to store the data for an analysis.
    #   @return [Types::AnalyticsExportDestination]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/StorageClassAnalysisDataExport AWS API Documentation
    #
    class StorageClassAnalysisDataExport < Struct.new(
      :output_schema_version,
      :destination)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Tag
    #   data as a hash:
    #
    #       {
    #         key: "ObjectKey", # required
    #         value: "Value", # required
    #       }
    #
    # @!attribute [rw] key
    #   Name of the tag.
    #   @return [String]
    #
    # @!attribute [rw] value
    #   Value of the tag.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Tag AWS API Documentation
    #
    class Tag < Struct.new(
      :key,
      :value)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Tagging
    #   data as a hash:
    #
    #       {
    #         tag_set: [ # required
    #           {
    #             key: "ObjectKey", # required
    #             value: "Value", # required
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] tag_set
    #   @return [Array<Types::Tag>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Tagging AWS API Documentation
    #
    class Tagging < Struct.new(
      :tag_set)
      include Aws::Structure
    end

    # @note When making an API call, you may pass TargetGrant
    #   data as a hash:
    #
    #       {
    #         grantee: {
    #           display_name: "DisplayName",
    #           email_address: "EmailAddress",
    #           id: "ID",
    #           type: "CanonicalUser", # required, accepts CanonicalUser, AmazonCustomerByEmail, Group
    #           uri: "URI",
    #         },
    #         permission: "FULL_CONTROL", # accepts FULL_CONTROL, READ, WRITE
    #       }
    #
    # @!attribute [rw] grantee
    #   @return [Types::Grantee]
    #
    # @!attribute [rw] permission
    #   Logging permissions assigned to the Grantee for the bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/TargetGrant AWS API Documentation
    #
    class TargetGrant < Struct.new(
      :grantee,
      :permission)
      include Aws::Structure
    end

    # Container for specifying the configuration when you want Amazon S3 to
    # publish events to an Amazon Simple Notification Service (Amazon SNS)
    # topic.
    #
    # @note When making an API call, you may pass TopicConfiguration
    #   data as a hash:
    #
    #       {
    #         id: "NotificationId",
    #         topic_arn: "TopicArn", # required
    #         events: ["s3:ReducedRedundancyLostObject"], # required, accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         filter: {
    #           key: {
    #             filter_rules: [
    #               {
    #                 name: "prefix", # accepts prefix, suffix
    #                 value: "FilterRuleValue",
    #               },
    #             ],
    #           },
    #         },
    #       }
    #
    # @!attribute [rw] id
    #   Optional unique identifier for configurations in a notification
    #   configuration. If you don't provide one, Amazon S3 will assign an
    #   ID.
    #   @return [String]
    #
    # @!attribute [rw] topic_arn
    #   Amazon SNS topic ARN to which Amazon S3 will publish a message when
    #   it detects events of specified type.
    #   @return [String]
    #
    # @!attribute [rw] events
    #   @return [Array<String>]
    #
    # @!attribute [rw] filter
    #   Container for object key name filtering rules. For information about
    #   key name filtering, go to [Configuring Event Notifications][1] in
    #   the Amazon Simple Storage Service Developer Guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
    #   @return [Types::NotificationConfigurationFilter]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/TopicConfiguration AWS API Documentation
    #
    class TopicConfiguration < Struct.new(
      :id,
      :topic_arn,
      :events,
      :filter)
      include Aws::Structure
    end

    # @note When making an API call, you may pass TopicConfigurationDeprecated
    #   data as a hash:
    #
    #       {
    #         id: "NotificationId",
    #         events: ["s3:ReducedRedundancyLostObject"], # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         event: "s3:ReducedRedundancyLostObject", # accepts s3:ReducedRedundancyLostObject, s3:ObjectCreated:*, s3:ObjectCreated:Put, s3:ObjectCreated:Post, s3:ObjectCreated:Copy, s3:ObjectCreated:CompleteMultipartUpload, s3:ObjectRemoved:*, s3:ObjectRemoved:Delete, s3:ObjectRemoved:DeleteMarkerCreated
    #         topic: "TopicArn",
    #       }
    #
    # @!attribute [rw] id
    #   Optional unique identifier for configurations in a notification
    #   configuration. If you don't provide one, Amazon S3 will assign an
    #   ID.
    #   @return [String]
    #
    # @!attribute [rw] events
    #   @return [Array<String>]
    #
    # @!attribute [rw] event
    #   Bucket event for which to send notifications.
    #   @return [String]
    #
    # @!attribute [rw] topic
    #   Amazon SNS topic to which Amazon S3 will publish a message to report
    #   the specified events for the bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/TopicConfigurationDeprecated AWS API Documentation
    #
    class TopicConfigurationDeprecated < Struct.new(
      :id,
      :events,
      :event,
      :topic)
      include Aws::Structure
    end

    # @note When making an API call, you may pass Transition
    #   data as a hash:
    #
    #       {
    #         date: Time.now,
    #         days: 1,
    #         storage_class: "GLACIER", # accepts GLACIER, STANDARD_IA, ONEZONE_IA
    #       }
    #
    # @!attribute [rw] date
    #   Indicates at what date the object is to be moved or deleted. Should
    #   be in GMT ISO 8601 Format.
    #   @return [Time]
    #
    # @!attribute [rw] days
    #   Indicates the lifetime, in days, of the objects that are subject to
    #   the rule. The value must be a non-zero positive integer.
    #   @return [Integer]
    #
    # @!attribute [rw] storage_class
    #   The class of storage used to store the object.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/Transition AWS API Documentation
    #
    class Transition < Struct.new(
      :date,
      :days,
      :storage_class)
      include Aws::Structure
    end

    # @!attribute [rw] copy_source_version_id
    #   The version of the source object that was copied, if you have
    #   enabled versioning on the source bucket.
    #   @return [String]
    #
    # @!attribute [rw] copy_part_result
    #   @return [Types::CopyPartResult]
    #
    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/UploadPartCopyOutput AWS API Documentation
    #
    class UploadPartCopyOutput < Struct.new(
      :copy_source_version_id,
      :copy_part_result,
      :server_side_encryption,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass UploadPartCopyRequest
    #   data as a hash:
    #
    #       {
    #         bucket: "BucketName", # required
    #         copy_source: "CopySource", # required
    #         copy_source_if_match: "CopySourceIfMatch",
    #         copy_source_if_modified_since: Time.now,
    #         copy_source_if_none_match: "CopySourceIfNoneMatch",
    #         copy_source_if_unmodified_since: Time.now,
    #         copy_source_range: "CopySourceRange",
    #         key: "ObjectKey", # required
    #         part_number: 1, # required
    #         upload_id: "MultipartUploadId", # required
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         copy_source_sse_customer_algorithm: "CopySourceSSECustomerAlgorithm",
    #         copy_source_sse_customer_key: "CopySourceSSECustomerKey",
    #         copy_source_sse_customer_key_md5: "CopySourceSSECustomerKeyMD5",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] bucket
    #   @return [String]
    #
    # @!attribute [rw] copy_source
    #   The name of the source bucket and key name of the source object,
    #   separated by a slash (/). Must be URL-encoded.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_if_match
    #   Copies the object if its entity tag (ETag) matches the specified
    #   tag.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_if_modified_since
    #   Copies the object if it has been modified since the specified time.
    #   @return [Time]
    #
    # @!attribute [rw] copy_source_if_none_match
    #   Copies the object if its entity tag (ETag) is different than the
    #   specified ETag.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_if_unmodified_since
    #   Copies the object if it hasn't been modified since the specified
    #   time.
    #   @return [Time]
    #
    # @!attribute [rw] copy_source_range
    #   The range of bytes to copy from the source object. The range value
    #   must use the form bytes=first-last, where the first and last are the
    #   zero-based byte offsets to copy. For example, bytes=0-9 indicates
    #   that you want to copy the first ten bytes of the source. You can
    #   copy a range only if the source object is greater than 5 GB.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   @return [String]
    #
    # @!attribute [rw] part_number
    #   Part number of part being copied. This is a positive integer between
    #   1 and 10,000.
    #   @return [Integer]
    #
    # @!attribute [rw] upload_id
    #   Upload ID identifying the multipart upload whose part is being
    #   copied.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header. This must
    #   be the same encryption key specified in the initiate multipart
    #   upload request.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_sse_customer_algorithm
    #   Specifies the algorithm to use when decrypting the source object
    #   (e.g., AES256).
    #   @return [String]
    #
    # @!attribute [rw] copy_source_sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   to decrypt the source object. The encryption key provided in this
    #   header must be one that was used when the source object was created.
    #   @return [String]
    #
    # @!attribute [rw] copy_source_sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/UploadPartCopyRequest AWS API Documentation
    #
    class UploadPartCopyRequest < Struct.new(
      :bucket,
      :copy_source,
      :copy_source_if_match,
      :copy_source_if_modified_since,
      :copy_source_if_none_match,
      :copy_source_if_unmodified_since,
      :copy_source_range,
      :key,
      :part_number,
      :upload_id,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :copy_source_sse_customer_algorithm,
      :copy_source_sse_customer_key,
      :copy_source_sse_customer_key_md5,
      :request_payer)
      include Aws::Structure
    end

    # @!attribute [rw] server_side_encryption
    #   The Server-side encryption algorithm used when storing this object
    #   in S3 (e.g., AES256, aws:kms).
    #   @return [String]
    #
    # @!attribute [rw] etag
    #   Entity tag for the uploaded object.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header confirming the
    #   encryption algorithm used.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   If server-side encryption with a customer-provided encryption key
    #   was requested, the response will include this header to provide
    #   round trip message integrity verification of the customer-provided
    #   encryption key.
    #   @return [String]
    #
    # @!attribute [rw] ssekms_key_id
    #   If present, specifies the ID of the AWS Key Management Service (KMS)
    #   master encryption key that was used for the object.
    #   @return [String]
    #
    # @!attribute [rw] request_charged
    #   If present, indicates that the requester was successfully charged
    #   for the request.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/UploadPartOutput AWS API Documentation
    #
    class UploadPartOutput < Struct.new(
      :server_side_encryption,
      :etag,
      :sse_customer_algorithm,
      :sse_customer_key_md5,
      :ssekms_key_id,
      :request_charged)
      include Aws::Structure
    end

    # @note When making an API call, you may pass UploadPartRequest
    #   data as a hash:
    #
    #       {
    #         body: source_file,
    #         bucket: "BucketName", # required
    #         content_length: 1,
    #         content_md5: "ContentMD5",
    #         key: "ObjectKey", # required
    #         part_number: 1, # required
    #         upload_id: "MultipartUploadId", # required
    #         sse_customer_algorithm: "SSECustomerAlgorithm",
    #         sse_customer_key: "SSECustomerKey",
    #         sse_customer_key_md5: "SSECustomerKeyMD5",
    #         request_payer: "requester", # accepts requester
    #       }
    #
    # @!attribute [rw] body
    #   Object data.
    #   @return [IO]
    #
    # @!attribute [rw] bucket
    #   Name of the bucket to which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] content_length
    #   Size of the body in bytes. This parameter is useful when the size of
    #   the body cannot be determined automatically.
    #   @return [Integer]
    #
    # @!attribute [rw] content_md5
    #   The base64-encoded 128-bit MD5 digest of the part data.
    #   @return [String]
    #
    # @!attribute [rw] key
    #   Object key for which the multipart upload was initiated.
    #   @return [String]
    #
    # @!attribute [rw] part_number
    #   Part number of part being uploaded. This is a positive integer
    #   between 1 and 10,000.
    #   @return [Integer]
    #
    # @!attribute [rw] upload_id
    #   Upload ID identifying the multipart upload whose part is being
    #   uploaded.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_algorithm
    #   Specifies the algorithm to use to when encrypting the object (e.g.,
    #   AES256).
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key
    #   Specifies the customer-provided encryption key for Amazon S3 to use
    #   in encrypting data. This value is used to store the object and then
    #   it is discarded; Amazon does not store the encryption key. The key
    #   must be appropriate for use with the algorithm specified in the
    #   x-amz-server-side​-encryption​-customer-algorithm header. This must
    #   be the same encryption key specified in the initiate multipart
    #   upload request.
    #   @return [String]
    #
    # @!attribute [rw] sse_customer_key_md5
    #   Specifies the 128-bit MD5 digest of the encryption key according to
    #   RFC 1321. Amazon S3 uses this header for a message integrity check
    #   to ensure the encryption key was transmitted without error.
    #   @return [String]
    #
    # @!attribute [rw] request_payer
    #   Confirms that the requester knows that she or he will be charged for
    #   the request. Bucket owners need not specify this parameter in their
    #   requests. Documentation on downloading objects from requester pays
    #   buckets can be found at
    #   http://docs.aws.amazon.com/AmazonS3/latest/dev/ObjectsinRequesterPaysBuckets.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/UploadPartRequest AWS API Documentation
    #
    class UploadPartRequest < Struct.new(
      :body,
      :bucket,
      :content_length,
      :content_md5,
      :key,
      :part_number,
      :upload_id,
      :sse_customer_algorithm,
      :sse_customer_key,
      :sse_customer_key_md5,
      :request_payer)
      include Aws::Structure
    end

    # @note When making an API call, you may pass VersioningConfiguration
    #   data as a hash:
    #
    #       {
    #         mfa_delete: "Enabled", # accepts Enabled, Disabled
    #         status: "Enabled", # accepts Enabled, Suspended
    #       }
    #
    # @!attribute [rw] mfa_delete
    #   Specifies whether MFA delete is enabled in the bucket versioning
    #   configuration. This element is only returned if the bucket has been
    #   configured with MFA delete. If the bucket has never been so
    #   configured, this element is not returned.
    #   @return [String]
    #
    # @!attribute [rw] status
    #   The versioning state of the bucket.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/VersioningConfiguration AWS API Documentation
    #
    class VersioningConfiguration < Struct.new(
      :mfa_delete,
      :status)
      include Aws::Structure
    end

    # @note When making an API call, you may pass WebsiteConfiguration
    #   data as a hash:
    #
    #       {
    #         error_document: {
    #           key: "ObjectKey", # required
    #         },
    #         index_document: {
    #           suffix: "Suffix", # required
    #         },
    #         redirect_all_requests_to: {
    #           host_name: "HostName", # required
    #           protocol: "http", # accepts http, https
    #         },
    #         routing_rules: [
    #           {
    #             condition: {
    #               http_error_code_returned_equals: "HttpErrorCodeReturnedEquals",
    #               key_prefix_equals: "KeyPrefixEquals",
    #             },
    #             redirect: { # required
    #               host_name: "HostName",
    #               http_redirect_code: "HttpRedirectCode",
    #               protocol: "http", # accepts http, https
    #               replace_key_prefix_with: "ReplaceKeyPrefixWith",
    #               replace_key_with: "ReplaceKeyWith",
    #             },
    #           },
    #         ],
    #       }
    #
    # @!attribute [rw] error_document
    #   @return [Types::ErrorDocument]
    #
    # @!attribute [rw] index_document
    #   @return [Types::IndexDocument]
    #
    # @!attribute [rw] redirect_all_requests_to
    #   @return [Types::RedirectAllRequestsTo]
    #
    # @!attribute [rw] routing_rules
    #   @return [Array<Types::RoutingRule>]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/s3-2006-03-01/WebsiteConfiguration AWS API Documentation
    #
    class WebsiteConfiguration < Struct.new(
      :error_document,
      :index_document,
      :redirect_all_requests_to,
      :routing_rules)
      include Aws::Structure
    end

  end
end
