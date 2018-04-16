# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::S3
  # @api private
  module ClientApi

    include Seahorse::Model

    AbortDate = Shapes::TimestampShape.new(name: 'AbortDate')
    AbortIncompleteMultipartUpload = Shapes::StructureShape.new(name: 'AbortIncompleteMultipartUpload')
    AbortMultipartUploadOutput = Shapes::StructureShape.new(name: 'AbortMultipartUploadOutput')
    AbortMultipartUploadRequest = Shapes::StructureShape.new(name: 'AbortMultipartUploadRequest')
    AbortRuleId = Shapes::StringShape.new(name: 'AbortRuleId')
    AccelerateConfiguration = Shapes::StructureShape.new(name: 'AccelerateConfiguration')
    AcceptRanges = Shapes::StringShape.new(name: 'AcceptRanges')
    AccessControlPolicy = Shapes::StructureShape.new(name: 'AccessControlPolicy')
    AccessControlTranslation = Shapes::StructureShape.new(name: 'AccessControlTranslation')
    AccountId = Shapes::StringShape.new(name: 'AccountId')
    AllowedHeader = Shapes::StringShape.new(name: 'AllowedHeader')
    AllowedHeaders = Shapes::ListShape.new(name: 'AllowedHeaders', flattened: true)
    AllowedMethod = Shapes::StringShape.new(name: 'AllowedMethod')
    AllowedMethods = Shapes::ListShape.new(name: 'AllowedMethods', flattened: true)
    AllowedOrigin = Shapes::StringShape.new(name: 'AllowedOrigin')
    AllowedOrigins = Shapes::ListShape.new(name: 'AllowedOrigins', flattened: true)
    AnalyticsAndOperator = Shapes::StructureShape.new(name: 'AnalyticsAndOperator')
    AnalyticsConfiguration = Shapes::StructureShape.new(name: 'AnalyticsConfiguration')
    AnalyticsConfigurationList = Shapes::ListShape.new(name: 'AnalyticsConfigurationList', flattened: true)
    AnalyticsExportDestination = Shapes::StructureShape.new(name: 'AnalyticsExportDestination')
    AnalyticsFilter = Shapes::StructureShape.new(name: 'AnalyticsFilter')
    AnalyticsId = Shapes::StringShape.new(name: 'AnalyticsId')
    AnalyticsS3BucketDestination = Shapes::StructureShape.new(name: 'AnalyticsS3BucketDestination')
    AnalyticsS3ExportFileFormat = Shapes::StringShape.new(name: 'AnalyticsS3ExportFileFormat')
    Body = Shapes::BlobShape.new(name: 'Body')
    Bucket = Shapes::StructureShape.new(name: 'Bucket')
    BucketAccelerateStatus = Shapes::StringShape.new(name: 'BucketAccelerateStatus')
    BucketAlreadyExists = Shapes::StructureShape.new(name: 'BucketAlreadyExists')
    BucketAlreadyOwnedByYou = Shapes::StructureShape.new(name: 'BucketAlreadyOwnedByYou')
    BucketCannedACL = Shapes::StringShape.new(name: 'BucketCannedACL')
    BucketLifecycleConfiguration = Shapes::StructureShape.new(name: 'BucketLifecycleConfiguration')
    BucketLocationConstraint = Shapes::StringShape.new(name: 'BucketLocationConstraint')
    BucketLoggingStatus = Shapes::StructureShape.new(name: 'BucketLoggingStatus')
    BucketLogsPermission = Shapes::StringShape.new(name: 'BucketLogsPermission')
    BucketName = Shapes::StringShape.new(name: 'BucketName')
    BucketVersioningStatus = Shapes::StringShape.new(name: 'BucketVersioningStatus')
    Buckets = Shapes::ListShape.new(name: 'Buckets')
    BytesProcessed = Shapes::IntegerShape.new(name: 'BytesProcessed')
    BytesScanned = Shapes::IntegerShape.new(name: 'BytesScanned')
    CORSConfiguration = Shapes::StructureShape.new(name: 'CORSConfiguration')
    CORSRule = Shapes::StructureShape.new(name: 'CORSRule')
    CORSRules = Shapes::ListShape.new(name: 'CORSRules', flattened: true)
    CSVInput = Shapes::StructureShape.new(name: 'CSVInput')
    CSVOutput = Shapes::StructureShape.new(name: 'CSVOutput')
    CacheControl = Shapes::StringShape.new(name: 'CacheControl')
    CloudFunction = Shapes::StringShape.new(name: 'CloudFunction')
    CloudFunctionConfiguration = Shapes::StructureShape.new(name: 'CloudFunctionConfiguration')
    CloudFunctionInvocationRole = Shapes::StringShape.new(name: 'CloudFunctionInvocationRole')
    Code = Shapes::StringShape.new(name: 'Code')
    Comments = Shapes::StringShape.new(name: 'Comments')
    CommonPrefix = Shapes::StructureShape.new(name: 'CommonPrefix')
    CommonPrefixList = Shapes::ListShape.new(name: 'CommonPrefixList', flattened: true)
    CompleteMultipartUploadOutput = Shapes::StructureShape.new(name: 'CompleteMultipartUploadOutput')
    CompleteMultipartUploadRequest = Shapes::StructureShape.new(name: 'CompleteMultipartUploadRequest')
    CompletedMultipartUpload = Shapes::StructureShape.new(name: 'CompletedMultipartUpload')
    CompletedPart = Shapes::StructureShape.new(name: 'CompletedPart')
    CompletedPartList = Shapes::ListShape.new(name: 'CompletedPartList', flattened: true)
    CompressionType = Shapes::StringShape.new(name: 'CompressionType')
    Condition = Shapes::StructureShape.new(name: 'Condition')
    ConfirmRemoveSelfBucketAccess = Shapes::BooleanShape.new(name: 'ConfirmRemoveSelfBucketAccess')
    ContentDisposition = Shapes::StringShape.new(name: 'ContentDisposition')
    ContentEncoding = Shapes::StringShape.new(name: 'ContentEncoding')
    ContentLanguage = Shapes::StringShape.new(name: 'ContentLanguage')
    ContentLength = Shapes::IntegerShape.new(name: 'ContentLength')
    ContentMD5 = Shapes::StringShape.new(name: 'ContentMD5')
    ContentRange = Shapes::StringShape.new(name: 'ContentRange')
    ContentType = Shapes::StringShape.new(name: 'ContentType')
    CopyObjectOutput = Shapes::StructureShape.new(name: 'CopyObjectOutput')
    CopyObjectRequest = Shapes::StructureShape.new(name: 'CopyObjectRequest')
    CopyObjectResult = Shapes::StructureShape.new(name: 'CopyObjectResult')
    CopyPartResult = Shapes::StructureShape.new(name: 'CopyPartResult')
    CopySource = Shapes::StringShape.new(name: 'CopySource')
    CopySourceIfMatch = Shapes::StringShape.new(name: 'CopySourceIfMatch')
    CopySourceIfModifiedSince = Shapes::TimestampShape.new(name: 'CopySourceIfModifiedSince')
    CopySourceIfNoneMatch = Shapes::StringShape.new(name: 'CopySourceIfNoneMatch')
    CopySourceIfUnmodifiedSince = Shapes::TimestampShape.new(name: 'CopySourceIfUnmodifiedSince')
    CopySourceRange = Shapes::StringShape.new(name: 'CopySourceRange')
    CopySourceSSECustomerAlgorithm = Shapes::StringShape.new(name: 'CopySourceSSECustomerAlgorithm')
    CopySourceSSECustomerKey = Shapes::StringShape.new(name: 'CopySourceSSECustomerKey')
    CopySourceSSECustomerKeyMD5 = Shapes::StringShape.new(name: 'CopySourceSSECustomerKeyMD5')
    CopySourceVersionId = Shapes::StringShape.new(name: 'CopySourceVersionId')
    CreateBucketConfiguration = Shapes::StructureShape.new(name: 'CreateBucketConfiguration')
    CreateBucketOutput = Shapes::StructureShape.new(name: 'CreateBucketOutput')
    CreateBucketRequest = Shapes::StructureShape.new(name: 'CreateBucketRequest')
    CreateMultipartUploadOutput = Shapes::StructureShape.new(name: 'CreateMultipartUploadOutput')
    CreateMultipartUploadRequest = Shapes::StructureShape.new(name: 'CreateMultipartUploadRequest')
    CreationDate = Shapes::TimestampShape.new(name: 'CreationDate')
    Date = Shapes::TimestampShape.new(name: 'Date', timestampFormat: "iso8601")
    Days = Shapes::IntegerShape.new(name: 'Days')
    DaysAfterInitiation = Shapes::IntegerShape.new(name: 'DaysAfterInitiation')
    Delete = Shapes::StructureShape.new(name: 'Delete')
    DeleteBucketAnalyticsConfigurationRequest = Shapes::StructureShape.new(name: 'DeleteBucketAnalyticsConfigurationRequest')
    DeleteBucketCorsRequest = Shapes::StructureShape.new(name: 'DeleteBucketCorsRequest')
    DeleteBucketEncryptionRequest = Shapes::StructureShape.new(name: 'DeleteBucketEncryptionRequest')
    DeleteBucketInventoryConfigurationRequest = Shapes::StructureShape.new(name: 'DeleteBucketInventoryConfigurationRequest')
    DeleteBucketLifecycleRequest = Shapes::StructureShape.new(name: 'DeleteBucketLifecycleRequest')
    DeleteBucketMetricsConfigurationRequest = Shapes::StructureShape.new(name: 'DeleteBucketMetricsConfigurationRequest')
    DeleteBucketPolicyRequest = Shapes::StructureShape.new(name: 'DeleteBucketPolicyRequest')
    DeleteBucketReplicationRequest = Shapes::StructureShape.new(name: 'DeleteBucketReplicationRequest')
    DeleteBucketRequest = Shapes::StructureShape.new(name: 'DeleteBucketRequest')
    DeleteBucketTaggingRequest = Shapes::StructureShape.new(name: 'DeleteBucketTaggingRequest')
    DeleteBucketWebsiteRequest = Shapes::StructureShape.new(name: 'DeleteBucketWebsiteRequest')
    DeleteMarker = Shapes::BooleanShape.new(name: 'DeleteMarker')
    DeleteMarkerEntry = Shapes::StructureShape.new(name: 'DeleteMarkerEntry')
    DeleteMarkerVersionId = Shapes::StringShape.new(name: 'DeleteMarkerVersionId')
    DeleteMarkers = Shapes::ListShape.new(name: 'DeleteMarkers', flattened: true)
    DeleteObjectOutput = Shapes::StructureShape.new(name: 'DeleteObjectOutput')
    DeleteObjectRequest = Shapes::StructureShape.new(name: 'DeleteObjectRequest')
    DeleteObjectTaggingOutput = Shapes::StructureShape.new(name: 'DeleteObjectTaggingOutput')
    DeleteObjectTaggingRequest = Shapes::StructureShape.new(name: 'DeleteObjectTaggingRequest')
    DeleteObjectsOutput = Shapes::StructureShape.new(name: 'DeleteObjectsOutput')
    DeleteObjectsRequest = Shapes::StructureShape.new(name: 'DeleteObjectsRequest')
    DeletedObject = Shapes::StructureShape.new(name: 'DeletedObject')
    DeletedObjects = Shapes::ListShape.new(name: 'DeletedObjects', flattened: true)
    Delimiter = Shapes::StringShape.new(name: 'Delimiter')
    Description = Shapes::StringShape.new(name: 'Description')
    Destination = Shapes::StructureShape.new(name: 'Destination')
    DisplayName = Shapes::StringShape.new(name: 'DisplayName')
    ETag = Shapes::StringShape.new(name: 'ETag')
    EmailAddress = Shapes::StringShape.new(name: 'EmailAddress')
    EnableRequestProgress = Shapes::BooleanShape.new(name: 'EnableRequestProgress')
    EncodingType = Shapes::StringShape.new(name: 'EncodingType')
    Encryption = Shapes::StructureShape.new(name: 'Encryption')
    EncryptionConfiguration = Shapes::StructureShape.new(name: 'EncryptionConfiguration')
    Error = Shapes::StructureShape.new(name: 'Error')
    ErrorDocument = Shapes::StructureShape.new(name: 'ErrorDocument')
    Errors = Shapes::ListShape.new(name: 'Errors', flattened: true)
    Event = Shapes::StringShape.new(name: 'Event')
    EventList = Shapes::ListShape.new(name: 'EventList', flattened: true)
    Expiration = Shapes::StringShape.new(name: 'Expiration')
    ExpirationStatus = Shapes::StringShape.new(name: 'ExpirationStatus')
    ExpiredObjectDeleteMarker = Shapes::BooleanShape.new(name: 'ExpiredObjectDeleteMarker')
    Expires = Shapes::TimestampShape.new(name: 'Expires')
    ExpiresString = Shapes::StringShape.new(name: 'ExpiresString')
    ExposeHeader = Shapes::StringShape.new(name: 'ExposeHeader')
    ExposeHeaders = Shapes::ListShape.new(name: 'ExposeHeaders', flattened: true)
    Expression = Shapes::StringShape.new(name: 'Expression')
    ExpressionType = Shapes::StringShape.new(name: 'ExpressionType')
    FetchOwner = Shapes::BooleanShape.new(name: 'FetchOwner')
    FieldDelimiter = Shapes::StringShape.new(name: 'FieldDelimiter')
    FileHeaderInfo = Shapes::StringShape.new(name: 'FileHeaderInfo')
    FilterRule = Shapes::StructureShape.new(name: 'FilterRule')
    FilterRuleList = Shapes::ListShape.new(name: 'FilterRuleList', flattened: true)
    FilterRuleName = Shapes::StringShape.new(name: 'FilterRuleName')
    FilterRuleValue = Shapes::StringShape.new(name: 'FilterRuleValue')
    GetBucketAccelerateConfigurationOutput = Shapes::StructureShape.new(name: 'GetBucketAccelerateConfigurationOutput')
    GetBucketAccelerateConfigurationRequest = Shapes::StructureShape.new(name: 'GetBucketAccelerateConfigurationRequest')
    GetBucketAclOutput = Shapes::StructureShape.new(name: 'GetBucketAclOutput')
    GetBucketAclRequest = Shapes::StructureShape.new(name: 'GetBucketAclRequest')
    GetBucketAnalyticsConfigurationOutput = Shapes::StructureShape.new(name: 'GetBucketAnalyticsConfigurationOutput')
    GetBucketAnalyticsConfigurationRequest = Shapes::StructureShape.new(name: 'GetBucketAnalyticsConfigurationRequest')
    GetBucketCorsOutput = Shapes::StructureShape.new(name: 'GetBucketCorsOutput')
    GetBucketCorsRequest = Shapes::StructureShape.new(name: 'GetBucketCorsRequest')
    GetBucketEncryptionOutput = Shapes::StructureShape.new(name: 'GetBucketEncryptionOutput')
    GetBucketEncryptionRequest = Shapes::StructureShape.new(name: 'GetBucketEncryptionRequest')
    GetBucketInventoryConfigurationOutput = Shapes::StructureShape.new(name: 'GetBucketInventoryConfigurationOutput')
    GetBucketInventoryConfigurationRequest = Shapes::StructureShape.new(name: 'GetBucketInventoryConfigurationRequest')
    GetBucketLifecycleConfigurationOutput = Shapes::StructureShape.new(name: 'GetBucketLifecycleConfigurationOutput')
    GetBucketLifecycleConfigurationRequest = Shapes::StructureShape.new(name: 'GetBucketLifecycleConfigurationRequest')
    GetBucketLifecycleOutput = Shapes::StructureShape.new(name: 'GetBucketLifecycleOutput')
    GetBucketLifecycleRequest = Shapes::StructureShape.new(name: 'GetBucketLifecycleRequest')
    GetBucketLocationOutput = Shapes::StructureShape.new(name: 'GetBucketLocationOutput')
    GetBucketLocationRequest = Shapes::StructureShape.new(name: 'GetBucketLocationRequest')
    GetBucketLoggingOutput = Shapes::StructureShape.new(name: 'GetBucketLoggingOutput')
    GetBucketLoggingRequest = Shapes::StructureShape.new(name: 'GetBucketLoggingRequest')
    GetBucketMetricsConfigurationOutput = Shapes::StructureShape.new(name: 'GetBucketMetricsConfigurationOutput')
    GetBucketMetricsConfigurationRequest = Shapes::StructureShape.new(name: 'GetBucketMetricsConfigurationRequest')
    GetBucketNotificationConfigurationRequest = Shapes::StructureShape.new(name: 'GetBucketNotificationConfigurationRequest')
    GetBucketPolicyOutput = Shapes::StructureShape.new(name: 'GetBucketPolicyOutput')
    GetBucketPolicyRequest = Shapes::StructureShape.new(name: 'GetBucketPolicyRequest')
    GetBucketReplicationOutput = Shapes::StructureShape.new(name: 'GetBucketReplicationOutput')
    GetBucketReplicationRequest = Shapes::StructureShape.new(name: 'GetBucketReplicationRequest')
    GetBucketRequestPaymentOutput = Shapes::StructureShape.new(name: 'GetBucketRequestPaymentOutput')
    GetBucketRequestPaymentRequest = Shapes::StructureShape.new(name: 'GetBucketRequestPaymentRequest')
    GetBucketTaggingOutput = Shapes::StructureShape.new(name: 'GetBucketTaggingOutput')
    GetBucketTaggingRequest = Shapes::StructureShape.new(name: 'GetBucketTaggingRequest')
    GetBucketVersioningOutput = Shapes::StructureShape.new(name: 'GetBucketVersioningOutput')
    GetBucketVersioningRequest = Shapes::StructureShape.new(name: 'GetBucketVersioningRequest')
    GetBucketWebsiteOutput = Shapes::StructureShape.new(name: 'GetBucketWebsiteOutput')
    GetBucketWebsiteRequest = Shapes::StructureShape.new(name: 'GetBucketWebsiteRequest')
    GetObjectAclOutput = Shapes::StructureShape.new(name: 'GetObjectAclOutput')
    GetObjectAclRequest = Shapes::StructureShape.new(name: 'GetObjectAclRequest')
    GetObjectOutput = Shapes::StructureShape.new(name: 'GetObjectOutput')
    GetObjectRequest = Shapes::StructureShape.new(name: 'GetObjectRequest')
    GetObjectTaggingOutput = Shapes::StructureShape.new(name: 'GetObjectTaggingOutput')
    GetObjectTaggingRequest = Shapes::StructureShape.new(name: 'GetObjectTaggingRequest')
    GetObjectTorrentOutput = Shapes::StructureShape.new(name: 'GetObjectTorrentOutput')
    GetObjectTorrentRequest = Shapes::StructureShape.new(name: 'GetObjectTorrentRequest')
    GlacierJobParameters = Shapes::StructureShape.new(name: 'GlacierJobParameters')
    Grant = Shapes::StructureShape.new(name: 'Grant')
    GrantFullControl = Shapes::StringShape.new(name: 'GrantFullControl')
    GrantRead = Shapes::StringShape.new(name: 'GrantRead')
    GrantReadACP = Shapes::StringShape.new(name: 'GrantReadACP')
    GrantWrite = Shapes::StringShape.new(name: 'GrantWrite')
    GrantWriteACP = Shapes::StringShape.new(name: 'GrantWriteACP')
    Grantee = Shapes::StructureShape.new(name: 'Grantee', xmlNamespace: {"prefix"=>"xsi", "uri"=>"http://www.w3.org/2001/XMLSchema-instance"})
    Grants = Shapes::ListShape.new(name: 'Grants')
    HeadBucketRequest = Shapes::StructureShape.new(name: 'HeadBucketRequest')
    HeadObjectOutput = Shapes::StructureShape.new(name: 'HeadObjectOutput')
    HeadObjectRequest = Shapes::StructureShape.new(name: 'HeadObjectRequest')
    HostName = Shapes::StringShape.new(name: 'HostName')
    HttpErrorCodeReturnedEquals = Shapes::StringShape.new(name: 'HttpErrorCodeReturnedEquals')
    HttpRedirectCode = Shapes::StringShape.new(name: 'HttpRedirectCode')
    ID = Shapes::StringShape.new(name: 'ID')
    IfMatch = Shapes::StringShape.new(name: 'IfMatch')
    IfModifiedSince = Shapes::TimestampShape.new(name: 'IfModifiedSince')
    IfNoneMatch = Shapes::StringShape.new(name: 'IfNoneMatch')
    IfUnmodifiedSince = Shapes::TimestampShape.new(name: 'IfUnmodifiedSince')
    IndexDocument = Shapes::StructureShape.new(name: 'IndexDocument')
    Initiated = Shapes::TimestampShape.new(name: 'Initiated')
    Initiator = Shapes::StructureShape.new(name: 'Initiator')
    InputSerialization = Shapes::StructureShape.new(name: 'InputSerialization')
    InventoryConfiguration = Shapes::StructureShape.new(name: 'InventoryConfiguration')
    InventoryConfigurationList = Shapes::ListShape.new(name: 'InventoryConfigurationList', flattened: true)
    InventoryDestination = Shapes::StructureShape.new(name: 'InventoryDestination')
    InventoryEncryption = Shapes::StructureShape.new(name: 'InventoryEncryption')
    InventoryFilter = Shapes::StructureShape.new(name: 'InventoryFilter')
    InventoryFormat = Shapes::StringShape.new(name: 'InventoryFormat')
    InventoryFrequency = Shapes::StringShape.new(name: 'InventoryFrequency')
    InventoryId = Shapes::StringShape.new(name: 'InventoryId')
    InventoryIncludedObjectVersions = Shapes::StringShape.new(name: 'InventoryIncludedObjectVersions')
    InventoryOptionalField = Shapes::StringShape.new(name: 'InventoryOptionalField')
    InventoryOptionalFields = Shapes::ListShape.new(name: 'InventoryOptionalFields')
    InventoryS3BucketDestination = Shapes::StructureShape.new(name: 'InventoryS3BucketDestination')
    InventorySchedule = Shapes::StructureShape.new(name: 'InventorySchedule')
    IsEnabled = Shapes::BooleanShape.new(name: 'IsEnabled')
    IsLatest = Shapes::BooleanShape.new(name: 'IsLatest')
    IsTruncated = Shapes::BooleanShape.new(name: 'IsTruncated')
    JSONInput = Shapes::StructureShape.new(name: 'JSONInput')
    JSONOutput = Shapes::StructureShape.new(name: 'JSONOutput')
    JSONType = Shapes::StringShape.new(name: 'JSONType')
    KMSContext = Shapes::StringShape.new(name: 'KMSContext')
    KeyCount = Shapes::IntegerShape.new(name: 'KeyCount')
    KeyMarker = Shapes::StringShape.new(name: 'KeyMarker')
    KeyPrefixEquals = Shapes::StringShape.new(name: 'KeyPrefixEquals')
    LambdaFunctionArn = Shapes::StringShape.new(name: 'LambdaFunctionArn')
    LambdaFunctionConfiguration = Shapes::StructureShape.new(name: 'LambdaFunctionConfiguration')
    LambdaFunctionConfigurationList = Shapes::ListShape.new(name: 'LambdaFunctionConfigurationList', flattened: true)
    LastModified = Shapes::TimestampShape.new(name: 'LastModified')
    LifecycleConfiguration = Shapes::StructureShape.new(name: 'LifecycleConfiguration')
    LifecycleExpiration = Shapes::StructureShape.new(name: 'LifecycleExpiration')
    LifecycleRule = Shapes::StructureShape.new(name: 'LifecycleRule')
    LifecycleRuleAndOperator = Shapes::StructureShape.new(name: 'LifecycleRuleAndOperator')
    LifecycleRuleFilter = Shapes::StructureShape.new(name: 'LifecycleRuleFilter')
    LifecycleRules = Shapes::ListShape.new(name: 'LifecycleRules', flattened: true)
    ListBucketAnalyticsConfigurationsOutput = Shapes::StructureShape.new(name: 'ListBucketAnalyticsConfigurationsOutput')
    ListBucketAnalyticsConfigurationsRequest = Shapes::StructureShape.new(name: 'ListBucketAnalyticsConfigurationsRequest')
    ListBucketInventoryConfigurationsOutput = Shapes::StructureShape.new(name: 'ListBucketInventoryConfigurationsOutput')
    ListBucketInventoryConfigurationsRequest = Shapes::StructureShape.new(name: 'ListBucketInventoryConfigurationsRequest')
    ListBucketMetricsConfigurationsOutput = Shapes::StructureShape.new(name: 'ListBucketMetricsConfigurationsOutput')
    ListBucketMetricsConfigurationsRequest = Shapes::StructureShape.new(name: 'ListBucketMetricsConfigurationsRequest')
    ListBucketsOutput = Shapes::StructureShape.new(name: 'ListBucketsOutput')
    ListMultipartUploadsOutput = Shapes::StructureShape.new(name: 'ListMultipartUploadsOutput')
    ListMultipartUploadsRequest = Shapes::StructureShape.new(name: 'ListMultipartUploadsRequest')
    ListObjectVersionsOutput = Shapes::StructureShape.new(name: 'ListObjectVersionsOutput')
    ListObjectVersionsRequest = Shapes::StructureShape.new(name: 'ListObjectVersionsRequest')
    ListObjectsOutput = Shapes::StructureShape.new(name: 'ListObjectsOutput')
    ListObjectsRequest = Shapes::StructureShape.new(name: 'ListObjectsRequest')
    ListObjectsV2Output = Shapes::StructureShape.new(name: 'ListObjectsV2Output')
    ListObjectsV2Request = Shapes::StructureShape.new(name: 'ListObjectsV2Request')
    ListPartsOutput = Shapes::StructureShape.new(name: 'ListPartsOutput')
    ListPartsRequest = Shapes::StructureShape.new(name: 'ListPartsRequest')
    Location = Shapes::StringShape.new(name: 'Location')
    LocationPrefix = Shapes::StringShape.new(name: 'LocationPrefix')
    LoggingEnabled = Shapes::StructureShape.new(name: 'LoggingEnabled')
    MFA = Shapes::StringShape.new(name: 'MFA')
    MFADelete = Shapes::StringShape.new(name: 'MFADelete')
    MFADeleteStatus = Shapes::StringShape.new(name: 'MFADeleteStatus')
    Marker = Shapes::StringShape.new(name: 'Marker')
    MaxAgeSeconds = Shapes::IntegerShape.new(name: 'MaxAgeSeconds')
    MaxKeys = Shapes::IntegerShape.new(name: 'MaxKeys')
    MaxParts = Shapes::IntegerShape.new(name: 'MaxParts')
    MaxUploads = Shapes::IntegerShape.new(name: 'MaxUploads')
    Message = Shapes::StringShape.new(name: 'Message')
    Metadata = Shapes::MapShape.new(name: 'Metadata')
    MetadataDirective = Shapes::StringShape.new(name: 'MetadataDirective')
    MetadataEntry = Shapes::StructureShape.new(name: 'MetadataEntry')
    MetadataKey = Shapes::StringShape.new(name: 'MetadataKey')
    MetadataValue = Shapes::StringShape.new(name: 'MetadataValue')
    MetricsAndOperator = Shapes::StructureShape.new(name: 'MetricsAndOperator')
    MetricsConfiguration = Shapes::StructureShape.new(name: 'MetricsConfiguration')
    MetricsConfigurationList = Shapes::ListShape.new(name: 'MetricsConfigurationList', flattened: true)
    MetricsFilter = Shapes::StructureShape.new(name: 'MetricsFilter')
    MetricsId = Shapes::StringShape.new(name: 'MetricsId')
    MissingMeta = Shapes::IntegerShape.new(name: 'MissingMeta')
    MultipartUpload = Shapes::StructureShape.new(name: 'MultipartUpload')
    MultipartUploadId = Shapes::StringShape.new(name: 'MultipartUploadId')
    MultipartUploadList = Shapes::ListShape.new(name: 'MultipartUploadList', flattened: true)
    NextKeyMarker = Shapes::StringShape.new(name: 'NextKeyMarker')
    NextMarker = Shapes::StringShape.new(name: 'NextMarker')
    NextPartNumberMarker = Shapes::IntegerShape.new(name: 'NextPartNumberMarker')
    NextToken = Shapes::StringShape.new(name: 'NextToken')
    NextUploadIdMarker = Shapes::StringShape.new(name: 'NextUploadIdMarker')
    NextVersionIdMarker = Shapes::StringShape.new(name: 'NextVersionIdMarker')
    NoSuchBucket = Shapes::StructureShape.new(name: 'NoSuchBucket')
    NoSuchKey = Shapes::StructureShape.new(name: 'NoSuchKey')
    NoSuchUpload = Shapes::StructureShape.new(name: 'NoSuchUpload')
    NoncurrentVersionExpiration = Shapes::StructureShape.new(name: 'NoncurrentVersionExpiration')
    NoncurrentVersionTransition = Shapes::StructureShape.new(name: 'NoncurrentVersionTransition')
    NoncurrentVersionTransitionList = Shapes::ListShape.new(name: 'NoncurrentVersionTransitionList', flattened: true)
    NotificationConfiguration = Shapes::StructureShape.new(name: 'NotificationConfiguration')
    NotificationConfigurationDeprecated = Shapes::StructureShape.new(name: 'NotificationConfigurationDeprecated')
    NotificationConfigurationFilter = Shapes::StructureShape.new(name: 'NotificationConfigurationFilter')
    NotificationId = Shapes::StringShape.new(name: 'NotificationId')
    Object = Shapes::StructureShape.new(name: 'Object')
    ObjectAlreadyInActiveTierError = Shapes::StructureShape.new(name: 'ObjectAlreadyInActiveTierError')
    ObjectCannedACL = Shapes::StringShape.new(name: 'ObjectCannedACL')
    ObjectIdentifier = Shapes::StructureShape.new(name: 'ObjectIdentifier')
    ObjectIdentifierList = Shapes::ListShape.new(name: 'ObjectIdentifierList', flattened: true)
    ObjectKey = Shapes::StringShape.new(name: 'ObjectKey')
    ObjectList = Shapes::ListShape.new(name: 'ObjectList', flattened: true)
    ObjectNotInActiveTierError = Shapes::StructureShape.new(name: 'ObjectNotInActiveTierError')
    ObjectStorageClass = Shapes::StringShape.new(name: 'ObjectStorageClass')
    ObjectVersion = Shapes::StructureShape.new(name: 'ObjectVersion')
    ObjectVersionId = Shapes::StringShape.new(name: 'ObjectVersionId')
    ObjectVersionList = Shapes::ListShape.new(name: 'ObjectVersionList', flattened: true)
    ObjectVersionStorageClass = Shapes::StringShape.new(name: 'ObjectVersionStorageClass')
    OutputLocation = Shapes::StructureShape.new(name: 'OutputLocation')
    OutputSerialization = Shapes::StructureShape.new(name: 'OutputSerialization')
    Owner = Shapes::StructureShape.new(name: 'Owner')
    OwnerOverride = Shapes::StringShape.new(name: 'OwnerOverride')
    Part = Shapes::StructureShape.new(name: 'Part')
    PartNumber = Shapes::IntegerShape.new(name: 'PartNumber')
    PartNumberMarker = Shapes::IntegerShape.new(name: 'PartNumberMarker')
    Parts = Shapes::ListShape.new(name: 'Parts', flattened: true)
    PartsCount = Shapes::IntegerShape.new(name: 'PartsCount')
    Payer = Shapes::StringShape.new(name: 'Payer')
    Permission = Shapes::StringShape.new(name: 'Permission')
    Policy = Shapes::StringShape.new(name: 'Policy')
    Prefix = Shapes::StringShape.new(name: 'Prefix')
    Progress = Shapes::StructureShape.new(name: 'Progress')
    Protocol = Shapes::StringShape.new(name: 'Protocol')
    PutBucketAccelerateConfigurationRequest = Shapes::StructureShape.new(name: 'PutBucketAccelerateConfigurationRequest')
    PutBucketAclRequest = Shapes::StructureShape.new(name: 'PutBucketAclRequest')
    PutBucketAnalyticsConfigurationRequest = Shapes::StructureShape.new(name: 'PutBucketAnalyticsConfigurationRequest')
    PutBucketCorsRequest = Shapes::StructureShape.new(name: 'PutBucketCorsRequest')
    PutBucketEncryptionRequest = Shapes::StructureShape.new(name: 'PutBucketEncryptionRequest')
    PutBucketInventoryConfigurationRequest = Shapes::StructureShape.new(name: 'PutBucketInventoryConfigurationRequest')
    PutBucketLifecycleConfigurationRequest = Shapes::StructureShape.new(name: 'PutBucketLifecycleConfigurationRequest')
    PutBucketLifecycleRequest = Shapes::StructureShape.new(name: 'PutBucketLifecycleRequest')
    PutBucketLoggingRequest = Shapes::StructureShape.new(name: 'PutBucketLoggingRequest')
    PutBucketMetricsConfigurationRequest = Shapes::StructureShape.new(name: 'PutBucketMetricsConfigurationRequest')
    PutBucketNotificationConfigurationRequest = Shapes::StructureShape.new(name: 'PutBucketNotificationConfigurationRequest')
    PutBucketNotificationRequest = Shapes::StructureShape.new(name: 'PutBucketNotificationRequest')
    PutBucketPolicyRequest = Shapes::StructureShape.new(name: 'PutBucketPolicyRequest')
    PutBucketReplicationRequest = Shapes::StructureShape.new(name: 'PutBucketReplicationRequest')
    PutBucketRequestPaymentRequest = Shapes::StructureShape.new(name: 'PutBucketRequestPaymentRequest')
    PutBucketTaggingRequest = Shapes::StructureShape.new(name: 'PutBucketTaggingRequest')
    PutBucketVersioningRequest = Shapes::StructureShape.new(name: 'PutBucketVersioningRequest')
    PutBucketWebsiteRequest = Shapes::StructureShape.new(name: 'PutBucketWebsiteRequest')
    PutObjectAclOutput = Shapes::StructureShape.new(name: 'PutObjectAclOutput')
    PutObjectAclRequest = Shapes::StructureShape.new(name: 'PutObjectAclRequest')
    PutObjectOutput = Shapes::StructureShape.new(name: 'PutObjectOutput')
    PutObjectRequest = Shapes::StructureShape.new(name: 'PutObjectRequest')
    PutObjectTaggingOutput = Shapes::StructureShape.new(name: 'PutObjectTaggingOutput')
    PutObjectTaggingRequest = Shapes::StructureShape.new(name: 'PutObjectTaggingRequest')
    QueueArn = Shapes::StringShape.new(name: 'QueueArn')
    QueueConfiguration = Shapes::StructureShape.new(name: 'QueueConfiguration')
    QueueConfigurationDeprecated = Shapes::StructureShape.new(name: 'QueueConfigurationDeprecated')
    QueueConfigurationList = Shapes::ListShape.new(name: 'QueueConfigurationList', flattened: true)
    Quiet = Shapes::BooleanShape.new(name: 'Quiet')
    QuoteCharacter = Shapes::StringShape.new(name: 'QuoteCharacter')
    QuoteEscapeCharacter = Shapes::StringShape.new(name: 'QuoteEscapeCharacter')
    QuoteFields = Shapes::StringShape.new(name: 'QuoteFields')
    Range = Shapes::StringShape.new(name: 'Range')
    RecordDelimiter = Shapes::StringShape.new(name: 'RecordDelimiter')
    Redirect = Shapes::StructureShape.new(name: 'Redirect')
    RedirectAllRequestsTo = Shapes::StructureShape.new(name: 'RedirectAllRequestsTo')
    ReplaceKeyPrefixWith = Shapes::StringShape.new(name: 'ReplaceKeyPrefixWith')
    ReplaceKeyWith = Shapes::StringShape.new(name: 'ReplaceKeyWith')
    ReplicaKmsKeyID = Shapes::StringShape.new(name: 'ReplicaKmsKeyID')
    ReplicationConfiguration = Shapes::StructureShape.new(name: 'ReplicationConfiguration')
    ReplicationRule = Shapes::StructureShape.new(name: 'ReplicationRule')
    ReplicationRuleStatus = Shapes::StringShape.new(name: 'ReplicationRuleStatus')
    ReplicationRules = Shapes::ListShape.new(name: 'ReplicationRules', flattened: true)
    ReplicationStatus = Shapes::StringShape.new(name: 'ReplicationStatus')
    RequestCharged = Shapes::StringShape.new(name: 'RequestCharged')
    RequestPayer = Shapes::StringShape.new(name: 'RequestPayer')
    RequestPaymentConfiguration = Shapes::StructureShape.new(name: 'RequestPaymentConfiguration')
    RequestProgress = Shapes::StructureShape.new(name: 'RequestProgress')
    ResponseCacheControl = Shapes::StringShape.new(name: 'ResponseCacheControl')
    ResponseContentDisposition = Shapes::StringShape.new(name: 'ResponseContentDisposition')
    ResponseContentEncoding = Shapes::StringShape.new(name: 'ResponseContentEncoding')
    ResponseContentLanguage = Shapes::StringShape.new(name: 'ResponseContentLanguage')
    ResponseContentType = Shapes::StringShape.new(name: 'ResponseContentType')
    ResponseExpires = Shapes::TimestampShape.new(name: 'ResponseExpires')
    Restore = Shapes::StringShape.new(name: 'Restore')
    RestoreObjectOutput = Shapes::StructureShape.new(name: 'RestoreObjectOutput')
    RestoreObjectRequest = Shapes::StructureShape.new(name: 'RestoreObjectRequest')
    RestoreOutputPath = Shapes::StringShape.new(name: 'RestoreOutputPath')
    RestoreRequest = Shapes::StructureShape.new(name: 'RestoreRequest')
    RestoreRequestType = Shapes::StringShape.new(name: 'RestoreRequestType')
    Role = Shapes::StringShape.new(name: 'Role')
    RoutingRule = Shapes::StructureShape.new(name: 'RoutingRule')
    RoutingRules = Shapes::ListShape.new(name: 'RoutingRules')
    Rule = Shapes::StructureShape.new(name: 'Rule')
    Rules = Shapes::ListShape.new(name: 'Rules', flattened: true)
    S3KeyFilter = Shapes::StructureShape.new(name: 'S3KeyFilter')
    S3Location = Shapes::StructureShape.new(name: 'S3Location')
    SSECustomerAlgorithm = Shapes::StringShape.new(name: 'SSECustomerAlgorithm')
    SSECustomerKey = Shapes::StringShape.new(name: 'SSECustomerKey')
    SSECustomerKeyMD5 = Shapes::StringShape.new(name: 'SSECustomerKeyMD5')
    SSEKMS = Shapes::StructureShape.new(name: 'SSEKMS')
    SSEKMSKeyId = Shapes::StringShape.new(name: 'SSEKMSKeyId')
    SSES3 = Shapes::StructureShape.new(name: 'SSES3')
    SelectParameters = Shapes::StructureShape.new(name: 'SelectParameters')
    ServerSideEncryption = Shapes::StringShape.new(name: 'ServerSideEncryption')
    ServerSideEncryptionByDefault = Shapes::StructureShape.new(name: 'ServerSideEncryptionByDefault')
    ServerSideEncryptionConfiguration = Shapes::StructureShape.new(name: 'ServerSideEncryptionConfiguration')
    ServerSideEncryptionRule = Shapes::StructureShape.new(name: 'ServerSideEncryptionRule')
    ServerSideEncryptionRules = Shapes::ListShape.new(name: 'ServerSideEncryptionRules', flattened: true)
    Size = Shapes::IntegerShape.new(name: 'Size')
    SourceSelectionCriteria = Shapes::StructureShape.new(name: 'SourceSelectionCriteria')
    SseKmsEncryptedObjects = Shapes::StructureShape.new(name: 'SseKmsEncryptedObjects')
    SseKmsEncryptedObjectsStatus = Shapes::StringShape.new(name: 'SseKmsEncryptedObjectsStatus')
    StartAfter = Shapes::StringShape.new(name: 'StartAfter')
    Stats = Shapes::StructureShape.new(name: 'Stats')
    StorageClass = Shapes::StringShape.new(name: 'StorageClass')
    StorageClassAnalysis = Shapes::StructureShape.new(name: 'StorageClassAnalysis')
    StorageClassAnalysisDataExport = Shapes::StructureShape.new(name: 'StorageClassAnalysisDataExport')
    StorageClassAnalysisSchemaVersion = Shapes::StringShape.new(name: 'StorageClassAnalysisSchemaVersion')
    Suffix = Shapes::StringShape.new(name: 'Suffix')
    Tag = Shapes::StructureShape.new(name: 'Tag')
    TagCount = Shapes::IntegerShape.new(name: 'TagCount')
    TagSet = Shapes::ListShape.new(name: 'TagSet')
    Tagging = Shapes::StructureShape.new(name: 'Tagging')
    TaggingDirective = Shapes::StringShape.new(name: 'TaggingDirective')
    TaggingHeader = Shapes::StringShape.new(name: 'TaggingHeader')
    TargetBucket = Shapes::StringShape.new(name: 'TargetBucket')
    TargetGrant = Shapes::StructureShape.new(name: 'TargetGrant')
    TargetGrants = Shapes::ListShape.new(name: 'TargetGrants')
    TargetPrefix = Shapes::StringShape.new(name: 'TargetPrefix')
    Tier = Shapes::StringShape.new(name: 'Tier')
    Token = Shapes::StringShape.new(name: 'Token')
    TopicArn = Shapes::StringShape.new(name: 'TopicArn')
    TopicConfiguration = Shapes::StructureShape.new(name: 'TopicConfiguration')
    TopicConfigurationDeprecated = Shapes::StructureShape.new(name: 'TopicConfigurationDeprecated')
    TopicConfigurationList = Shapes::ListShape.new(name: 'TopicConfigurationList', flattened: true)
    Transition = Shapes::StructureShape.new(name: 'Transition')
    TransitionList = Shapes::ListShape.new(name: 'TransitionList', flattened: true)
    TransitionStorageClass = Shapes::StringShape.new(name: 'TransitionStorageClass')
    Type = Shapes::StringShape.new(name: 'Type')
    URI = Shapes::StringShape.new(name: 'URI')
    UploadIdMarker = Shapes::StringShape.new(name: 'UploadIdMarker')
    UploadPartCopyOutput = Shapes::StructureShape.new(name: 'UploadPartCopyOutput')
    UploadPartCopyRequest = Shapes::StructureShape.new(name: 'UploadPartCopyRequest')
    UploadPartOutput = Shapes::StructureShape.new(name: 'UploadPartOutput')
    UploadPartRequest = Shapes::StructureShape.new(name: 'UploadPartRequest')
    UserMetadata = Shapes::ListShape.new(name: 'UserMetadata')
    Value = Shapes::StringShape.new(name: 'Value')
    VersionIdMarker = Shapes::StringShape.new(name: 'VersionIdMarker')
    VersioningConfiguration = Shapes::StructureShape.new(name: 'VersioningConfiguration')
    WebsiteConfiguration = Shapes::StructureShape.new(name: 'WebsiteConfiguration')
    WebsiteRedirectLocation = Shapes::StringShape.new(name: 'WebsiteRedirectLocation')

    AbortIncompleteMultipartUpload.add_member(:days_after_initiation, Shapes::ShapeRef.new(shape: DaysAfterInitiation, location_name: "DaysAfterInitiation"))
    AbortIncompleteMultipartUpload.struct_class = Types::AbortIncompleteMultipartUpload

    AbortMultipartUploadOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    AbortMultipartUploadOutput.struct_class = Types::AbortMultipartUploadOutput

    AbortMultipartUploadRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    AbortMultipartUploadRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    AbortMultipartUploadRequest.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, required: true, location: "querystring", location_name: "uploadId"))
    AbortMultipartUploadRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    AbortMultipartUploadRequest.struct_class = Types::AbortMultipartUploadRequest

    AccelerateConfiguration.add_member(:status, Shapes::ShapeRef.new(shape: BucketAccelerateStatus, location_name: "Status"))
    AccelerateConfiguration.struct_class = Types::AccelerateConfiguration

    AccessControlPolicy.add_member(:grants, Shapes::ShapeRef.new(shape: Grants, location_name: "AccessControlList"))
    AccessControlPolicy.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    AccessControlPolicy.struct_class = Types::AccessControlPolicy

    AccessControlTranslation.add_member(:owner, Shapes::ShapeRef.new(shape: OwnerOverride, required: true, location_name: "Owner"))
    AccessControlTranslation.struct_class = Types::AccessControlTranslation

    AllowedHeaders.member = Shapes::ShapeRef.new(shape: AllowedHeader)

    AllowedMethods.member = Shapes::ShapeRef.new(shape: AllowedMethod)

    AllowedOrigins.member = Shapes::ShapeRef.new(shape: AllowedOrigin)

    AnalyticsAndOperator.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    AnalyticsAndOperator.add_member(:tags, Shapes::ShapeRef.new(shape: TagSet, location_name: "Tag", metadata: {"flattened"=>true}))
    AnalyticsAndOperator.struct_class = Types::AnalyticsAndOperator

    AnalyticsConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: AnalyticsId, required: true, location_name: "Id"))
    AnalyticsConfiguration.add_member(:filter, Shapes::ShapeRef.new(shape: AnalyticsFilter, location_name: "Filter"))
    AnalyticsConfiguration.add_member(:storage_class_analysis, Shapes::ShapeRef.new(shape: StorageClassAnalysis, required: true, location_name: "StorageClassAnalysis"))
    AnalyticsConfiguration.struct_class = Types::AnalyticsConfiguration

    AnalyticsConfigurationList.member = Shapes::ShapeRef.new(shape: AnalyticsConfiguration)

    AnalyticsExportDestination.add_member(:s3_bucket_destination, Shapes::ShapeRef.new(shape: AnalyticsS3BucketDestination, required: true, location_name: "S3BucketDestination"))
    AnalyticsExportDestination.struct_class = Types::AnalyticsExportDestination

    AnalyticsFilter.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    AnalyticsFilter.add_member(:tag, Shapes::ShapeRef.new(shape: Tag, location_name: "Tag"))
    AnalyticsFilter.add_member(:and, Shapes::ShapeRef.new(shape: AnalyticsAndOperator, location_name: "And"))
    AnalyticsFilter.struct_class = Types::AnalyticsFilter

    AnalyticsS3BucketDestination.add_member(:format, Shapes::ShapeRef.new(shape: AnalyticsS3ExportFileFormat, required: true, location_name: "Format"))
    AnalyticsS3BucketDestination.add_member(:bucket_account_id, Shapes::ShapeRef.new(shape: AccountId, location_name: "BucketAccountId"))
    AnalyticsS3BucketDestination.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location_name: "Bucket"))
    AnalyticsS3BucketDestination.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    AnalyticsS3BucketDestination.struct_class = Types::AnalyticsS3BucketDestination

    Bucket.add_member(:name, Shapes::ShapeRef.new(shape: BucketName, location_name: "Name"))
    Bucket.add_member(:creation_date, Shapes::ShapeRef.new(shape: CreationDate, location_name: "CreationDate"))
    Bucket.struct_class = Types::Bucket

    BucketLifecycleConfiguration.add_member(:rules, Shapes::ShapeRef.new(shape: LifecycleRules, required: true, location_name: "Rule"))
    BucketLifecycleConfiguration.struct_class = Types::BucketLifecycleConfiguration

    BucketLoggingStatus.add_member(:logging_enabled, Shapes::ShapeRef.new(shape: LoggingEnabled, location_name: "LoggingEnabled"))
    BucketLoggingStatus.struct_class = Types::BucketLoggingStatus

    Buckets.member = Shapes::ShapeRef.new(shape: Bucket, location_name: "Bucket")

    CORSConfiguration.add_member(:cors_rules, Shapes::ShapeRef.new(shape: CORSRules, required: true, location_name: "CORSRule"))
    CORSConfiguration.struct_class = Types::CORSConfiguration

    CORSRule.add_member(:allowed_headers, Shapes::ShapeRef.new(shape: AllowedHeaders, location_name: "AllowedHeader"))
    CORSRule.add_member(:allowed_methods, Shapes::ShapeRef.new(shape: AllowedMethods, required: true, location_name: "AllowedMethod"))
    CORSRule.add_member(:allowed_origins, Shapes::ShapeRef.new(shape: AllowedOrigins, required: true, location_name: "AllowedOrigin"))
    CORSRule.add_member(:expose_headers, Shapes::ShapeRef.new(shape: ExposeHeaders, location_name: "ExposeHeader"))
    CORSRule.add_member(:max_age_seconds, Shapes::ShapeRef.new(shape: MaxAgeSeconds, location_name: "MaxAgeSeconds"))
    CORSRule.struct_class = Types::CORSRule

    CORSRules.member = Shapes::ShapeRef.new(shape: CORSRule)

    CSVInput.add_member(:file_header_info, Shapes::ShapeRef.new(shape: FileHeaderInfo, location_name: "FileHeaderInfo"))
    CSVInput.add_member(:comments, Shapes::ShapeRef.new(shape: Comments, location_name: "Comments"))
    CSVInput.add_member(:quote_escape_character, Shapes::ShapeRef.new(shape: QuoteEscapeCharacter, location_name: "QuoteEscapeCharacter"))
    CSVInput.add_member(:record_delimiter, Shapes::ShapeRef.new(shape: RecordDelimiter, location_name: "RecordDelimiter"))
    CSVInput.add_member(:field_delimiter, Shapes::ShapeRef.new(shape: FieldDelimiter, location_name: "FieldDelimiter"))
    CSVInput.add_member(:quote_character, Shapes::ShapeRef.new(shape: QuoteCharacter, location_name: "QuoteCharacter"))
    CSVInput.struct_class = Types::CSVInput

    CSVOutput.add_member(:quote_fields, Shapes::ShapeRef.new(shape: QuoteFields, location_name: "QuoteFields"))
    CSVOutput.add_member(:quote_escape_character, Shapes::ShapeRef.new(shape: QuoteEscapeCharacter, location_name: "QuoteEscapeCharacter"))
    CSVOutput.add_member(:record_delimiter, Shapes::ShapeRef.new(shape: RecordDelimiter, location_name: "RecordDelimiter"))
    CSVOutput.add_member(:field_delimiter, Shapes::ShapeRef.new(shape: FieldDelimiter, location_name: "FieldDelimiter"))
    CSVOutput.add_member(:quote_character, Shapes::ShapeRef.new(shape: QuoteCharacter, location_name: "QuoteCharacter"))
    CSVOutput.struct_class = Types::CSVOutput

    CloudFunctionConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: NotificationId, location_name: "Id"))
    CloudFunctionConfiguration.add_member(:event, Shapes::ShapeRef.new(shape: Event, deprecated: true, location_name: "Event"))
    CloudFunctionConfiguration.add_member(:events, Shapes::ShapeRef.new(shape: EventList, location_name: "Event"))
    CloudFunctionConfiguration.add_member(:cloud_function, Shapes::ShapeRef.new(shape: CloudFunction, location_name: "CloudFunction"))
    CloudFunctionConfiguration.add_member(:invocation_role, Shapes::ShapeRef.new(shape: CloudFunctionInvocationRole, location_name: "InvocationRole"))
    CloudFunctionConfiguration.struct_class = Types::CloudFunctionConfiguration

    CommonPrefix.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    CommonPrefix.struct_class = Types::CommonPrefix

    CommonPrefixList.member = Shapes::ShapeRef.new(shape: CommonPrefix)

    CompleteMultipartUploadOutput.add_member(:location, Shapes::ShapeRef.new(shape: Location, location_name: "Location"))
    CompleteMultipartUploadOutput.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, location_name: "Bucket"))
    CompleteMultipartUploadOutput.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    CompleteMultipartUploadOutput.add_member(:expiration, Shapes::ShapeRef.new(shape: Expiration, location: "header", location_name: "x-amz-expiration"))
    CompleteMultipartUploadOutput.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    CompleteMultipartUploadOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    CompleteMultipartUploadOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    CompleteMultipartUploadOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    CompleteMultipartUploadOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    CompleteMultipartUploadOutput.struct_class = Types::CompleteMultipartUploadOutput

    CompleteMultipartUploadRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    CompleteMultipartUploadRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    CompleteMultipartUploadRequest.add_member(:multipart_upload, Shapes::ShapeRef.new(shape: CompletedMultipartUpload, location_name: "CompleteMultipartUpload", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    CompleteMultipartUploadRequest.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, required: true, location: "querystring", location_name: "uploadId"))
    CompleteMultipartUploadRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    CompleteMultipartUploadRequest.struct_class = Types::CompleteMultipartUploadRequest
    CompleteMultipartUploadRequest[:payload] = :multipart_upload
    CompleteMultipartUploadRequest[:payload_member] = CompleteMultipartUploadRequest.member(:multipart_upload)

    CompletedMultipartUpload.add_member(:parts, Shapes::ShapeRef.new(shape: CompletedPartList, location_name: "Part"))
    CompletedMultipartUpload.struct_class = Types::CompletedMultipartUpload

    CompletedPart.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    CompletedPart.add_member(:part_number, Shapes::ShapeRef.new(shape: PartNumber, location_name: "PartNumber"))
    CompletedPart.struct_class = Types::CompletedPart

    CompletedPartList.member = Shapes::ShapeRef.new(shape: CompletedPart)

    Condition.add_member(:http_error_code_returned_equals, Shapes::ShapeRef.new(shape: HttpErrorCodeReturnedEquals, location_name: "HttpErrorCodeReturnedEquals"))
    Condition.add_member(:key_prefix_equals, Shapes::ShapeRef.new(shape: KeyPrefixEquals, location_name: "KeyPrefixEquals"))
    Condition.struct_class = Types::Condition

    CopyObjectOutput.add_member(:copy_object_result, Shapes::ShapeRef.new(shape: CopyObjectResult, location_name: "CopyObjectResult"))
    CopyObjectOutput.add_member(:expiration, Shapes::ShapeRef.new(shape: Expiration, location: "header", location_name: "x-amz-expiration"))
    CopyObjectOutput.add_member(:copy_source_version_id, Shapes::ShapeRef.new(shape: CopySourceVersionId, location: "header", location_name: "x-amz-copy-source-version-id"))
    CopyObjectOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    CopyObjectOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    CopyObjectOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    CopyObjectOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    CopyObjectOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    CopyObjectOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    CopyObjectOutput.struct_class = Types::CopyObjectOutput
    CopyObjectOutput[:payload] = :copy_object_result
    CopyObjectOutput[:payload_member] = CopyObjectOutput.member(:copy_object_result)

    CopyObjectRequest.add_member(:acl, Shapes::ShapeRef.new(shape: ObjectCannedACL, location: "header", location_name: "x-amz-acl"))
    CopyObjectRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    CopyObjectRequest.add_member(:cache_control, Shapes::ShapeRef.new(shape: CacheControl, location: "header", location_name: "Cache-Control"))
    CopyObjectRequest.add_member(:content_disposition, Shapes::ShapeRef.new(shape: ContentDisposition, location: "header", location_name: "Content-Disposition"))
    CopyObjectRequest.add_member(:content_encoding, Shapes::ShapeRef.new(shape: ContentEncoding, location: "header", location_name: "Content-Encoding"))
    CopyObjectRequest.add_member(:content_language, Shapes::ShapeRef.new(shape: ContentLanguage, location: "header", location_name: "Content-Language"))
    CopyObjectRequest.add_member(:content_type, Shapes::ShapeRef.new(shape: ContentType, location: "header", location_name: "Content-Type"))
    CopyObjectRequest.add_member(:copy_source, Shapes::ShapeRef.new(shape: CopySource, required: true, location: "header", location_name: "x-amz-copy-source"))
    CopyObjectRequest.add_member(:copy_source_if_match, Shapes::ShapeRef.new(shape: CopySourceIfMatch, location: "header", location_name: "x-amz-copy-source-if-match"))
    CopyObjectRequest.add_member(:copy_source_if_modified_since, Shapes::ShapeRef.new(shape: CopySourceIfModifiedSince, location: "header", location_name: "x-amz-copy-source-if-modified-since"))
    CopyObjectRequest.add_member(:copy_source_if_none_match, Shapes::ShapeRef.new(shape: CopySourceIfNoneMatch, location: "header", location_name: "x-amz-copy-source-if-none-match"))
    CopyObjectRequest.add_member(:copy_source_if_unmodified_since, Shapes::ShapeRef.new(shape: CopySourceIfUnmodifiedSince, location: "header", location_name: "x-amz-copy-source-if-unmodified-since"))
    CopyObjectRequest.add_member(:expires, Shapes::ShapeRef.new(shape: Expires, location: "header", location_name: "Expires"))
    CopyObjectRequest.add_member(:grant_full_control, Shapes::ShapeRef.new(shape: GrantFullControl, location: "header", location_name: "x-amz-grant-full-control"))
    CopyObjectRequest.add_member(:grant_read, Shapes::ShapeRef.new(shape: GrantRead, location: "header", location_name: "x-amz-grant-read"))
    CopyObjectRequest.add_member(:grant_read_acp, Shapes::ShapeRef.new(shape: GrantReadACP, location: "header", location_name: "x-amz-grant-read-acp"))
    CopyObjectRequest.add_member(:grant_write_acp, Shapes::ShapeRef.new(shape: GrantWriteACP, location: "header", location_name: "x-amz-grant-write-acp"))
    CopyObjectRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    CopyObjectRequest.add_member(:metadata, Shapes::ShapeRef.new(shape: Metadata, location: "headers", location_name: "x-amz-meta-"))
    CopyObjectRequest.add_member(:metadata_directive, Shapes::ShapeRef.new(shape: MetadataDirective, location: "header", location_name: "x-amz-metadata-directive"))
    CopyObjectRequest.add_member(:tagging_directive, Shapes::ShapeRef.new(shape: TaggingDirective, location: "header", location_name: "x-amz-tagging-directive"))
    CopyObjectRequest.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    CopyObjectRequest.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location: "header", location_name: "x-amz-storage-class"))
    CopyObjectRequest.add_member(:website_redirect_location, Shapes::ShapeRef.new(shape: WebsiteRedirectLocation, location: "header", location_name: "x-amz-website-redirect-location"))
    CopyObjectRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    CopyObjectRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    CopyObjectRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    CopyObjectRequest.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    CopyObjectRequest.add_member(:copy_source_sse_customer_algorithm, Shapes::ShapeRef.new(shape: CopySourceSSECustomerAlgorithm, location: "header", location_name: "x-amz-copy-source-server-side-encryption-customer-algorithm"))
    CopyObjectRequest.add_member(:copy_source_sse_customer_key, Shapes::ShapeRef.new(shape: CopySourceSSECustomerKey, location: "header", location_name: "x-amz-copy-source-server-side-encryption-customer-key"))
    CopyObjectRequest.add_member(:copy_source_sse_customer_key_md5, Shapes::ShapeRef.new(shape: CopySourceSSECustomerKeyMD5, location: "header", location_name: "x-amz-copy-source-server-side-encryption-customer-key-MD5"))
    CopyObjectRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    CopyObjectRequest.add_member(:tagging, Shapes::ShapeRef.new(shape: TaggingHeader, location: "header", location_name: "x-amz-tagging"))
    CopyObjectRequest.struct_class = Types::CopyObjectRequest

    CopyObjectResult.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    CopyObjectResult.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location_name: "LastModified"))
    CopyObjectResult.struct_class = Types::CopyObjectResult

    CopyPartResult.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    CopyPartResult.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location_name: "LastModified"))
    CopyPartResult.struct_class = Types::CopyPartResult

    CreateBucketConfiguration.add_member(:location_constraint, Shapes::ShapeRef.new(shape: BucketLocationConstraint, location_name: "LocationConstraint"))
    CreateBucketConfiguration.struct_class = Types::CreateBucketConfiguration

    CreateBucketOutput.add_member(:location, Shapes::ShapeRef.new(shape: Location, location: "header", location_name: "Location"))
    CreateBucketOutput.struct_class = Types::CreateBucketOutput

    CreateBucketRequest.add_member(:acl, Shapes::ShapeRef.new(shape: BucketCannedACL, location: "header", location_name: "x-amz-acl"))
    CreateBucketRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    CreateBucketRequest.add_member(:create_bucket_configuration, Shapes::ShapeRef.new(shape: CreateBucketConfiguration, location_name: "CreateBucketConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    CreateBucketRequest.add_member(:grant_full_control, Shapes::ShapeRef.new(shape: GrantFullControl, location: "header", location_name: "x-amz-grant-full-control"))
    CreateBucketRequest.add_member(:grant_read, Shapes::ShapeRef.new(shape: GrantRead, location: "header", location_name: "x-amz-grant-read"))
    CreateBucketRequest.add_member(:grant_read_acp, Shapes::ShapeRef.new(shape: GrantReadACP, location: "header", location_name: "x-amz-grant-read-acp"))
    CreateBucketRequest.add_member(:grant_write, Shapes::ShapeRef.new(shape: GrantWrite, location: "header", location_name: "x-amz-grant-write"))
    CreateBucketRequest.add_member(:grant_write_acp, Shapes::ShapeRef.new(shape: GrantWriteACP, location: "header", location_name: "x-amz-grant-write-acp"))
    CreateBucketRequest.struct_class = Types::CreateBucketRequest
    CreateBucketRequest[:payload] = :create_bucket_configuration
    CreateBucketRequest[:payload_member] = CreateBucketRequest.member(:create_bucket_configuration)

    CreateMultipartUploadOutput.add_member(:abort_date, Shapes::ShapeRef.new(shape: AbortDate, location: "header", location_name: "x-amz-abort-date"))
    CreateMultipartUploadOutput.add_member(:abort_rule_id, Shapes::ShapeRef.new(shape: AbortRuleId, location: "header", location_name: "x-amz-abort-rule-id"))
    CreateMultipartUploadOutput.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, location_name: "Bucket"))
    CreateMultipartUploadOutput.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    CreateMultipartUploadOutput.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, location_name: "UploadId"))
    CreateMultipartUploadOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    CreateMultipartUploadOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    CreateMultipartUploadOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    CreateMultipartUploadOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    CreateMultipartUploadOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    CreateMultipartUploadOutput.struct_class = Types::CreateMultipartUploadOutput

    CreateMultipartUploadRequest.add_member(:acl, Shapes::ShapeRef.new(shape: ObjectCannedACL, location: "header", location_name: "x-amz-acl"))
    CreateMultipartUploadRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    CreateMultipartUploadRequest.add_member(:cache_control, Shapes::ShapeRef.new(shape: CacheControl, location: "header", location_name: "Cache-Control"))
    CreateMultipartUploadRequest.add_member(:content_disposition, Shapes::ShapeRef.new(shape: ContentDisposition, location: "header", location_name: "Content-Disposition"))
    CreateMultipartUploadRequest.add_member(:content_encoding, Shapes::ShapeRef.new(shape: ContentEncoding, location: "header", location_name: "Content-Encoding"))
    CreateMultipartUploadRequest.add_member(:content_language, Shapes::ShapeRef.new(shape: ContentLanguage, location: "header", location_name: "Content-Language"))
    CreateMultipartUploadRequest.add_member(:content_type, Shapes::ShapeRef.new(shape: ContentType, location: "header", location_name: "Content-Type"))
    CreateMultipartUploadRequest.add_member(:expires, Shapes::ShapeRef.new(shape: Expires, location: "header", location_name: "Expires"))
    CreateMultipartUploadRequest.add_member(:grant_full_control, Shapes::ShapeRef.new(shape: GrantFullControl, location: "header", location_name: "x-amz-grant-full-control"))
    CreateMultipartUploadRequest.add_member(:grant_read, Shapes::ShapeRef.new(shape: GrantRead, location: "header", location_name: "x-amz-grant-read"))
    CreateMultipartUploadRequest.add_member(:grant_read_acp, Shapes::ShapeRef.new(shape: GrantReadACP, location: "header", location_name: "x-amz-grant-read-acp"))
    CreateMultipartUploadRequest.add_member(:grant_write_acp, Shapes::ShapeRef.new(shape: GrantWriteACP, location: "header", location_name: "x-amz-grant-write-acp"))
    CreateMultipartUploadRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    CreateMultipartUploadRequest.add_member(:metadata, Shapes::ShapeRef.new(shape: Metadata, location: "headers", location_name: "x-amz-meta-"))
    CreateMultipartUploadRequest.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    CreateMultipartUploadRequest.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location: "header", location_name: "x-amz-storage-class"))
    CreateMultipartUploadRequest.add_member(:website_redirect_location, Shapes::ShapeRef.new(shape: WebsiteRedirectLocation, location: "header", location_name: "x-amz-website-redirect-location"))
    CreateMultipartUploadRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    CreateMultipartUploadRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    CreateMultipartUploadRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    CreateMultipartUploadRequest.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    CreateMultipartUploadRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    CreateMultipartUploadRequest.add_member(:tagging, Shapes::ShapeRef.new(shape: TaggingHeader, location: "header", location_name: "x-amz-tagging"))
    CreateMultipartUploadRequest.struct_class = Types::CreateMultipartUploadRequest

    Delete.add_member(:objects, Shapes::ShapeRef.new(shape: ObjectIdentifierList, required: true, location_name: "Object"))
    Delete.add_member(:quiet, Shapes::ShapeRef.new(shape: Quiet, location_name: "Quiet"))
    Delete.struct_class = Types::Delete

    DeleteBucketAnalyticsConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketAnalyticsConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: AnalyticsId, required: true, location: "querystring", location_name: "id"))
    DeleteBucketAnalyticsConfigurationRequest.struct_class = Types::DeleteBucketAnalyticsConfigurationRequest

    DeleteBucketCorsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketCorsRequest.struct_class = Types::DeleteBucketCorsRequest

    DeleteBucketEncryptionRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketEncryptionRequest.struct_class = Types::DeleteBucketEncryptionRequest

    DeleteBucketInventoryConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketInventoryConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: InventoryId, required: true, location: "querystring", location_name: "id"))
    DeleteBucketInventoryConfigurationRequest.struct_class = Types::DeleteBucketInventoryConfigurationRequest

    DeleteBucketLifecycleRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketLifecycleRequest.struct_class = Types::DeleteBucketLifecycleRequest

    DeleteBucketMetricsConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketMetricsConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: MetricsId, required: true, location: "querystring", location_name: "id"))
    DeleteBucketMetricsConfigurationRequest.struct_class = Types::DeleteBucketMetricsConfigurationRequest

    DeleteBucketPolicyRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketPolicyRequest.struct_class = Types::DeleteBucketPolicyRequest

    DeleteBucketReplicationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketReplicationRequest.struct_class = Types::DeleteBucketReplicationRequest

    DeleteBucketRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketRequest.struct_class = Types::DeleteBucketRequest

    DeleteBucketTaggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketTaggingRequest.struct_class = Types::DeleteBucketTaggingRequest

    DeleteBucketWebsiteRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteBucketWebsiteRequest.struct_class = Types::DeleteBucketWebsiteRequest

    DeleteMarkerEntry.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    DeleteMarkerEntry.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    DeleteMarkerEntry.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location_name: "VersionId"))
    DeleteMarkerEntry.add_member(:is_latest, Shapes::ShapeRef.new(shape: IsLatest, location_name: "IsLatest"))
    DeleteMarkerEntry.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location_name: "LastModified"))
    DeleteMarkerEntry.struct_class = Types::DeleteMarkerEntry

    DeleteMarkers.member = Shapes::ShapeRef.new(shape: DeleteMarkerEntry)

    DeleteObjectOutput.add_member(:delete_marker, Shapes::ShapeRef.new(shape: DeleteMarker, location: "header", location_name: "x-amz-delete-marker"))
    DeleteObjectOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    DeleteObjectOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    DeleteObjectOutput.struct_class = Types::DeleteObjectOutput

    DeleteObjectRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteObjectRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    DeleteObjectRequest.add_member(:mfa, Shapes::ShapeRef.new(shape: MFA, location: "header", location_name: "x-amz-mfa"))
    DeleteObjectRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    DeleteObjectRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    DeleteObjectRequest.struct_class = Types::DeleteObjectRequest

    DeleteObjectTaggingOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    DeleteObjectTaggingOutput.struct_class = Types::DeleteObjectTaggingOutput

    DeleteObjectTaggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteObjectTaggingRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    DeleteObjectTaggingRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    DeleteObjectTaggingRequest.struct_class = Types::DeleteObjectTaggingRequest

    DeleteObjectsOutput.add_member(:deleted, Shapes::ShapeRef.new(shape: DeletedObjects, location_name: "Deleted"))
    DeleteObjectsOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    DeleteObjectsOutput.add_member(:errors, Shapes::ShapeRef.new(shape: Errors, location_name: "Error"))
    DeleteObjectsOutput.struct_class = Types::DeleteObjectsOutput

    DeleteObjectsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    DeleteObjectsRequest.add_member(:delete, Shapes::ShapeRef.new(shape: Delete, required: true, location_name: "Delete", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    DeleteObjectsRequest.add_member(:mfa, Shapes::ShapeRef.new(shape: MFA, location: "header", location_name: "x-amz-mfa"))
    DeleteObjectsRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    DeleteObjectsRequest.struct_class = Types::DeleteObjectsRequest
    DeleteObjectsRequest[:payload] = :delete
    DeleteObjectsRequest[:payload_member] = DeleteObjectsRequest.member(:delete)

    DeletedObject.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    DeletedObject.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location_name: "VersionId"))
    DeletedObject.add_member(:delete_marker, Shapes::ShapeRef.new(shape: DeleteMarker, location_name: "DeleteMarker"))
    DeletedObject.add_member(:delete_marker_version_id, Shapes::ShapeRef.new(shape: DeleteMarkerVersionId, location_name: "DeleteMarkerVersionId"))
    DeletedObject.struct_class = Types::DeletedObject

    DeletedObjects.member = Shapes::ShapeRef.new(shape: DeletedObject)

    Destination.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location_name: "Bucket"))
    Destination.add_member(:account, Shapes::ShapeRef.new(shape: AccountId, location_name: "Account"))
    Destination.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location_name: "StorageClass"))
    Destination.add_member(:access_control_translation, Shapes::ShapeRef.new(shape: AccessControlTranslation, location_name: "AccessControlTranslation"))
    Destination.add_member(:encryption_configuration, Shapes::ShapeRef.new(shape: EncryptionConfiguration, location_name: "EncryptionConfiguration"))
    Destination.struct_class = Types::Destination

    Encryption.add_member(:encryption_type, Shapes::ShapeRef.new(shape: ServerSideEncryption, required: true, location_name: "EncryptionType"))
    Encryption.add_member(:kms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location_name: "KMSKeyId"))
    Encryption.add_member(:kms_context, Shapes::ShapeRef.new(shape: KMSContext, location_name: "KMSContext"))
    Encryption.struct_class = Types::Encryption

    EncryptionConfiguration.add_member(:replica_kms_key_id, Shapes::ShapeRef.new(shape: ReplicaKmsKeyID, location_name: "ReplicaKmsKeyID"))
    EncryptionConfiguration.struct_class = Types::EncryptionConfiguration

    Error.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    Error.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location_name: "VersionId"))
    Error.add_member(:code, Shapes::ShapeRef.new(shape: Code, location_name: "Code"))
    Error.add_member(:message, Shapes::ShapeRef.new(shape: Message, location_name: "Message"))
    Error.struct_class = Types::Error

    ErrorDocument.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location_name: "Key"))
    ErrorDocument.struct_class = Types::ErrorDocument

    Errors.member = Shapes::ShapeRef.new(shape: Error)

    EventList.member = Shapes::ShapeRef.new(shape: Event)

    ExposeHeaders.member = Shapes::ShapeRef.new(shape: ExposeHeader)

    FilterRule.add_member(:name, Shapes::ShapeRef.new(shape: FilterRuleName, location_name: "Name"))
    FilterRule.add_member(:value, Shapes::ShapeRef.new(shape: FilterRuleValue, location_name: "Value"))
    FilterRule.struct_class = Types::FilterRule

    FilterRuleList.member = Shapes::ShapeRef.new(shape: FilterRule)

    GetBucketAccelerateConfigurationOutput.add_member(:status, Shapes::ShapeRef.new(shape: BucketAccelerateStatus, location_name: "Status"))
    GetBucketAccelerateConfigurationOutput.struct_class = Types::GetBucketAccelerateConfigurationOutput

    GetBucketAccelerateConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketAccelerateConfigurationRequest.struct_class = Types::GetBucketAccelerateConfigurationRequest

    GetBucketAclOutput.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    GetBucketAclOutput.add_member(:grants, Shapes::ShapeRef.new(shape: Grants, location_name: "AccessControlList"))
    GetBucketAclOutput.struct_class = Types::GetBucketAclOutput

    GetBucketAclRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketAclRequest.struct_class = Types::GetBucketAclRequest

    GetBucketAnalyticsConfigurationOutput.add_member(:analytics_configuration, Shapes::ShapeRef.new(shape: AnalyticsConfiguration, location_name: "AnalyticsConfiguration"))
    GetBucketAnalyticsConfigurationOutput.struct_class = Types::GetBucketAnalyticsConfigurationOutput
    GetBucketAnalyticsConfigurationOutput[:payload] = :analytics_configuration
    GetBucketAnalyticsConfigurationOutput[:payload_member] = GetBucketAnalyticsConfigurationOutput.member(:analytics_configuration)

    GetBucketAnalyticsConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketAnalyticsConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: AnalyticsId, required: true, location: "querystring", location_name: "id"))
    GetBucketAnalyticsConfigurationRequest.struct_class = Types::GetBucketAnalyticsConfigurationRequest

    GetBucketCorsOutput.add_member(:cors_rules, Shapes::ShapeRef.new(shape: CORSRules, location_name: "CORSRule"))
    GetBucketCorsOutput.struct_class = Types::GetBucketCorsOutput

    GetBucketCorsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketCorsRequest.struct_class = Types::GetBucketCorsRequest

    GetBucketEncryptionOutput.add_member(:server_side_encryption_configuration, Shapes::ShapeRef.new(shape: ServerSideEncryptionConfiguration, location_name: "ServerSideEncryptionConfiguration"))
    GetBucketEncryptionOutput.struct_class = Types::GetBucketEncryptionOutput
    GetBucketEncryptionOutput[:payload] = :server_side_encryption_configuration
    GetBucketEncryptionOutput[:payload_member] = GetBucketEncryptionOutput.member(:server_side_encryption_configuration)

    GetBucketEncryptionRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketEncryptionRequest.struct_class = Types::GetBucketEncryptionRequest

    GetBucketInventoryConfigurationOutput.add_member(:inventory_configuration, Shapes::ShapeRef.new(shape: InventoryConfiguration, location_name: "InventoryConfiguration"))
    GetBucketInventoryConfigurationOutput.struct_class = Types::GetBucketInventoryConfigurationOutput
    GetBucketInventoryConfigurationOutput[:payload] = :inventory_configuration
    GetBucketInventoryConfigurationOutput[:payload_member] = GetBucketInventoryConfigurationOutput.member(:inventory_configuration)

    GetBucketInventoryConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketInventoryConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: InventoryId, required: true, location: "querystring", location_name: "id"))
    GetBucketInventoryConfigurationRequest.struct_class = Types::GetBucketInventoryConfigurationRequest

    GetBucketLifecycleConfigurationOutput.add_member(:rules, Shapes::ShapeRef.new(shape: LifecycleRules, location_name: "Rule"))
    GetBucketLifecycleConfigurationOutput.struct_class = Types::GetBucketLifecycleConfigurationOutput

    GetBucketLifecycleConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketLifecycleConfigurationRequest.struct_class = Types::GetBucketLifecycleConfigurationRequest

    GetBucketLifecycleOutput.add_member(:rules, Shapes::ShapeRef.new(shape: Rules, location_name: "Rule"))
    GetBucketLifecycleOutput.struct_class = Types::GetBucketLifecycleOutput

    GetBucketLifecycleRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketLifecycleRequest.struct_class = Types::GetBucketLifecycleRequest

    GetBucketLocationOutput.add_member(:location_constraint, Shapes::ShapeRef.new(shape: BucketLocationConstraint, location_name: "LocationConstraint"))
    GetBucketLocationOutput.struct_class = Types::GetBucketLocationOutput

    GetBucketLocationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketLocationRequest.struct_class = Types::GetBucketLocationRequest

    GetBucketLoggingOutput.add_member(:logging_enabled, Shapes::ShapeRef.new(shape: LoggingEnabled, location_name: "LoggingEnabled"))
    GetBucketLoggingOutput.struct_class = Types::GetBucketLoggingOutput

    GetBucketLoggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketLoggingRequest.struct_class = Types::GetBucketLoggingRequest

    GetBucketMetricsConfigurationOutput.add_member(:metrics_configuration, Shapes::ShapeRef.new(shape: MetricsConfiguration, location_name: "MetricsConfiguration"))
    GetBucketMetricsConfigurationOutput.struct_class = Types::GetBucketMetricsConfigurationOutput
    GetBucketMetricsConfigurationOutput[:payload] = :metrics_configuration
    GetBucketMetricsConfigurationOutput[:payload_member] = GetBucketMetricsConfigurationOutput.member(:metrics_configuration)

    GetBucketMetricsConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketMetricsConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: MetricsId, required: true, location: "querystring", location_name: "id"))
    GetBucketMetricsConfigurationRequest.struct_class = Types::GetBucketMetricsConfigurationRequest

    GetBucketNotificationConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketNotificationConfigurationRequest.struct_class = Types::GetBucketNotificationConfigurationRequest

    GetBucketPolicyOutput.add_member(:policy, Shapes::ShapeRef.new(shape: Policy, location_name: "Policy"))
    GetBucketPolicyOutput.struct_class = Types::GetBucketPolicyOutput
    GetBucketPolicyOutput[:payload] = :policy
    GetBucketPolicyOutput[:payload_member] = GetBucketPolicyOutput.member(:policy)

    GetBucketPolicyRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketPolicyRequest.struct_class = Types::GetBucketPolicyRequest

    GetBucketReplicationOutput.add_member(:replication_configuration, Shapes::ShapeRef.new(shape: ReplicationConfiguration, location_name: "ReplicationConfiguration"))
    GetBucketReplicationOutput.struct_class = Types::GetBucketReplicationOutput
    GetBucketReplicationOutput[:payload] = :replication_configuration
    GetBucketReplicationOutput[:payload_member] = GetBucketReplicationOutput.member(:replication_configuration)

    GetBucketReplicationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketReplicationRequest.struct_class = Types::GetBucketReplicationRequest

    GetBucketRequestPaymentOutput.add_member(:payer, Shapes::ShapeRef.new(shape: Payer, location_name: "Payer"))
    GetBucketRequestPaymentOutput.struct_class = Types::GetBucketRequestPaymentOutput

    GetBucketRequestPaymentRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketRequestPaymentRequest.struct_class = Types::GetBucketRequestPaymentRequest

    GetBucketTaggingOutput.add_member(:tag_set, Shapes::ShapeRef.new(shape: TagSet, required: true, location_name: "TagSet"))
    GetBucketTaggingOutput.struct_class = Types::GetBucketTaggingOutput

    GetBucketTaggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketTaggingRequest.struct_class = Types::GetBucketTaggingRequest

    GetBucketVersioningOutput.add_member(:status, Shapes::ShapeRef.new(shape: BucketVersioningStatus, location_name: "Status"))
    GetBucketVersioningOutput.add_member(:mfa_delete, Shapes::ShapeRef.new(shape: MFADeleteStatus, location_name: "MfaDelete"))
    GetBucketVersioningOutput.struct_class = Types::GetBucketVersioningOutput

    GetBucketVersioningRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketVersioningRequest.struct_class = Types::GetBucketVersioningRequest

    GetBucketWebsiteOutput.add_member(:redirect_all_requests_to, Shapes::ShapeRef.new(shape: RedirectAllRequestsTo, location_name: "RedirectAllRequestsTo"))
    GetBucketWebsiteOutput.add_member(:index_document, Shapes::ShapeRef.new(shape: IndexDocument, location_name: "IndexDocument"))
    GetBucketWebsiteOutput.add_member(:error_document, Shapes::ShapeRef.new(shape: ErrorDocument, location_name: "ErrorDocument"))
    GetBucketWebsiteOutput.add_member(:routing_rules, Shapes::ShapeRef.new(shape: RoutingRules, location_name: "RoutingRules"))
    GetBucketWebsiteOutput.struct_class = Types::GetBucketWebsiteOutput

    GetBucketWebsiteRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetBucketWebsiteRequest.struct_class = Types::GetBucketWebsiteRequest

    GetObjectAclOutput.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    GetObjectAclOutput.add_member(:grants, Shapes::ShapeRef.new(shape: Grants, location_name: "AccessControlList"))
    GetObjectAclOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    GetObjectAclOutput.struct_class = Types::GetObjectAclOutput

    GetObjectAclRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetObjectAclRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    GetObjectAclRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    GetObjectAclRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    GetObjectAclRequest.struct_class = Types::GetObjectAclRequest

    GetObjectOutput.add_member(:body, Shapes::ShapeRef.new(shape: Body, location_name: "Body", metadata: {"streaming"=>true}))
    GetObjectOutput.add_member(:delete_marker, Shapes::ShapeRef.new(shape: DeleteMarker, location: "header", location_name: "x-amz-delete-marker"))
    GetObjectOutput.add_member(:accept_ranges, Shapes::ShapeRef.new(shape: AcceptRanges, location: "header", location_name: "accept-ranges"))
    GetObjectOutput.add_member(:expiration, Shapes::ShapeRef.new(shape: Expiration, location: "header", location_name: "x-amz-expiration"))
    GetObjectOutput.add_member(:restore, Shapes::ShapeRef.new(shape: Restore, location: "header", location_name: "x-amz-restore"))
    GetObjectOutput.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location: "header", location_name: "Last-Modified"))
    GetObjectOutput.add_member(:content_length, Shapes::ShapeRef.new(shape: ContentLength, location: "header", location_name: "Content-Length"))
    GetObjectOutput.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location: "header", location_name: "ETag"))
    GetObjectOutput.add_member(:missing_meta, Shapes::ShapeRef.new(shape: MissingMeta, location: "header", location_name: "x-amz-missing-meta"))
    GetObjectOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    GetObjectOutput.add_member(:cache_control, Shapes::ShapeRef.new(shape: CacheControl, location: "header", location_name: "Cache-Control"))
    GetObjectOutput.add_member(:content_disposition, Shapes::ShapeRef.new(shape: ContentDisposition, location: "header", location_name: "Content-Disposition"))
    GetObjectOutput.add_member(:content_encoding, Shapes::ShapeRef.new(shape: ContentEncoding, location: "header", location_name: "Content-Encoding"))
    GetObjectOutput.add_member(:content_language, Shapes::ShapeRef.new(shape: ContentLanguage, location: "header", location_name: "Content-Language"))
    GetObjectOutput.add_member(:content_range, Shapes::ShapeRef.new(shape: ContentRange, location: "header", location_name: "Content-Range"))
    GetObjectOutput.add_member(:content_type, Shapes::ShapeRef.new(shape: ContentType, location: "header", location_name: "Content-Type"))
    GetObjectOutput.add_member(:expires, Shapes::ShapeRef.new(shape: Expires, location: "header", location_name: "Expires"))
    GetObjectOutput.add_member(:expires_string, Shapes::ShapeRef.new(shape: ExpiresString, location: "header", location_name: "Expires"))
    GetObjectOutput.add_member(:website_redirect_location, Shapes::ShapeRef.new(shape: WebsiteRedirectLocation, location: "header", location_name: "x-amz-website-redirect-location"))
    GetObjectOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    GetObjectOutput.add_member(:metadata, Shapes::ShapeRef.new(shape: Metadata, location: "headers", location_name: "x-amz-meta-"))
    GetObjectOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    GetObjectOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    GetObjectOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    GetObjectOutput.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location: "header", location_name: "x-amz-storage-class"))
    GetObjectOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    GetObjectOutput.add_member(:replication_status, Shapes::ShapeRef.new(shape: ReplicationStatus, location: "header", location_name: "x-amz-replication-status"))
    GetObjectOutput.add_member(:parts_count, Shapes::ShapeRef.new(shape: PartsCount, location: "header", location_name: "x-amz-mp-parts-count"))
    GetObjectOutput.add_member(:tag_count, Shapes::ShapeRef.new(shape: TagCount, location: "header", location_name: "x-amz-tagging-count"))
    GetObjectOutput.struct_class = Types::GetObjectOutput
    GetObjectOutput[:payload] = :body
    GetObjectOutput[:payload_member] = GetObjectOutput.member(:body)

    GetObjectRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetObjectRequest.add_member(:if_match, Shapes::ShapeRef.new(shape: IfMatch, location: "header", location_name: "If-Match"))
    GetObjectRequest.add_member(:if_modified_since, Shapes::ShapeRef.new(shape: IfModifiedSince, location: "header", location_name: "If-Modified-Since"))
    GetObjectRequest.add_member(:if_none_match, Shapes::ShapeRef.new(shape: IfNoneMatch, location: "header", location_name: "If-None-Match"))
    GetObjectRequest.add_member(:if_unmodified_since, Shapes::ShapeRef.new(shape: IfUnmodifiedSince, location: "header", location_name: "If-Unmodified-Since"))
    GetObjectRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    GetObjectRequest.add_member(:range, Shapes::ShapeRef.new(shape: Range, location: "header", location_name: "Range"))
    GetObjectRequest.add_member(:response_cache_control, Shapes::ShapeRef.new(shape: ResponseCacheControl, location: "querystring", location_name: "response-cache-control"))
    GetObjectRequest.add_member(:response_content_disposition, Shapes::ShapeRef.new(shape: ResponseContentDisposition, location: "querystring", location_name: "response-content-disposition"))
    GetObjectRequest.add_member(:response_content_encoding, Shapes::ShapeRef.new(shape: ResponseContentEncoding, location: "querystring", location_name: "response-content-encoding"))
    GetObjectRequest.add_member(:response_content_language, Shapes::ShapeRef.new(shape: ResponseContentLanguage, location: "querystring", location_name: "response-content-language"))
    GetObjectRequest.add_member(:response_content_type, Shapes::ShapeRef.new(shape: ResponseContentType, location: "querystring", location_name: "response-content-type"))
    GetObjectRequest.add_member(:response_expires, Shapes::ShapeRef.new(shape: ResponseExpires, location: "querystring", location_name: "response-expires"))
    GetObjectRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    GetObjectRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    GetObjectRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    GetObjectRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    GetObjectRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    GetObjectRequest.add_member(:part_number, Shapes::ShapeRef.new(shape: PartNumber, location: "querystring", location_name: "partNumber"))
    GetObjectRequest.struct_class = Types::GetObjectRequest

    GetObjectTaggingOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    GetObjectTaggingOutput.add_member(:tag_set, Shapes::ShapeRef.new(shape: TagSet, required: true, location_name: "TagSet"))
    GetObjectTaggingOutput.struct_class = Types::GetObjectTaggingOutput

    GetObjectTaggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetObjectTaggingRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    GetObjectTaggingRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    GetObjectTaggingRequest.struct_class = Types::GetObjectTaggingRequest

    GetObjectTorrentOutput.add_member(:body, Shapes::ShapeRef.new(shape: Body, location_name: "Body", metadata: {"streaming"=>true}))
    GetObjectTorrentOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    GetObjectTorrentOutput.struct_class = Types::GetObjectTorrentOutput
    GetObjectTorrentOutput[:payload] = :body
    GetObjectTorrentOutput[:payload_member] = GetObjectTorrentOutput.member(:body)

    GetObjectTorrentRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    GetObjectTorrentRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    GetObjectTorrentRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    GetObjectTorrentRequest.struct_class = Types::GetObjectTorrentRequest

    GlacierJobParameters.add_member(:tier, Shapes::ShapeRef.new(shape: Tier, required: true, location_name: "Tier"))
    GlacierJobParameters.struct_class = Types::GlacierJobParameters

    Grant.add_member(:grantee, Shapes::ShapeRef.new(shape: Grantee, location_name: "Grantee"))
    Grant.add_member(:permission, Shapes::ShapeRef.new(shape: Permission, location_name: "Permission"))
    Grant.struct_class = Types::Grant

    Grantee.add_member(:display_name, Shapes::ShapeRef.new(shape: DisplayName, location_name: "DisplayName"))
    Grantee.add_member(:email_address, Shapes::ShapeRef.new(shape: EmailAddress, location_name: "EmailAddress"))
    Grantee.add_member(:id, Shapes::ShapeRef.new(shape: ID, location_name: "ID"))
    Grantee.add_member(:type, Shapes::ShapeRef.new(shape: Type, required: true, location_name: "xsi:type", metadata: {"xmlAttribute"=>true}))
    Grantee.add_member(:uri, Shapes::ShapeRef.new(shape: URI, location_name: "URI"))
    Grantee.struct_class = Types::Grantee

    Grants.member = Shapes::ShapeRef.new(shape: Grant, location_name: "Grant")

    HeadBucketRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    HeadBucketRequest.struct_class = Types::HeadBucketRequest

    HeadObjectOutput.add_member(:delete_marker, Shapes::ShapeRef.new(shape: DeleteMarker, location: "header", location_name: "x-amz-delete-marker"))
    HeadObjectOutput.add_member(:accept_ranges, Shapes::ShapeRef.new(shape: AcceptRanges, location: "header", location_name: "accept-ranges"))
    HeadObjectOutput.add_member(:expiration, Shapes::ShapeRef.new(shape: Expiration, location: "header", location_name: "x-amz-expiration"))
    HeadObjectOutput.add_member(:restore, Shapes::ShapeRef.new(shape: Restore, location: "header", location_name: "x-amz-restore"))
    HeadObjectOutput.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location: "header", location_name: "Last-Modified"))
    HeadObjectOutput.add_member(:content_length, Shapes::ShapeRef.new(shape: ContentLength, location: "header", location_name: "Content-Length"))
    HeadObjectOutput.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location: "header", location_name: "ETag"))
    HeadObjectOutput.add_member(:missing_meta, Shapes::ShapeRef.new(shape: MissingMeta, location: "header", location_name: "x-amz-missing-meta"))
    HeadObjectOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    HeadObjectOutput.add_member(:cache_control, Shapes::ShapeRef.new(shape: CacheControl, location: "header", location_name: "Cache-Control"))
    HeadObjectOutput.add_member(:content_disposition, Shapes::ShapeRef.new(shape: ContentDisposition, location: "header", location_name: "Content-Disposition"))
    HeadObjectOutput.add_member(:content_encoding, Shapes::ShapeRef.new(shape: ContentEncoding, location: "header", location_name: "Content-Encoding"))
    HeadObjectOutput.add_member(:content_language, Shapes::ShapeRef.new(shape: ContentLanguage, location: "header", location_name: "Content-Language"))
    HeadObjectOutput.add_member(:content_type, Shapes::ShapeRef.new(shape: ContentType, location: "header", location_name: "Content-Type"))
    HeadObjectOutput.add_member(:expires, Shapes::ShapeRef.new(shape: Expires, location: "header", location_name: "Expires"))
    HeadObjectOutput.add_member(:expires_string, Shapes::ShapeRef.new(shape: ExpiresString, location: "header", location_name: "Expires"))
    HeadObjectOutput.add_member(:website_redirect_location, Shapes::ShapeRef.new(shape: WebsiteRedirectLocation, location: "header", location_name: "x-amz-website-redirect-location"))
    HeadObjectOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    HeadObjectOutput.add_member(:metadata, Shapes::ShapeRef.new(shape: Metadata, location: "headers", location_name: "x-amz-meta-"))
    HeadObjectOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    HeadObjectOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    HeadObjectOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    HeadObjectOutput.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location: "header", location_name: "x-amz-storage-class"))
    HeadObjectOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    HeadObjectOutput.add_member(:replication_status, Shapes::ShapeRef.new(shape: ReplicationStatus, location: "header", location_name: "x-amz-replication-status"))
    HeadObjectOutput.add_member(:parts_count, Shapes::ShapeRef.new(shape: PartsCount, location: "header", location_name: "x-amz-mp-parts-count"))
    HeadObjectOutput.struct_class = Types::HeadObjectOutput

    HeadObjectRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    HeadObjectRequest.add_member(:if_match, Shapes::ShapeRef.new(shape: IfMatch, location: "header", location_name: "If-Match"))
    HeadObjectRequest.add_member(:if_modified_since, Shapes::ShapeRef.new(shape: IfModifiedSince, location: "header", location_name: "If-Modified-Since"))
    HeadObjectRequest.add_member(:if_none_match, Shapes::ShapeRef.new(shape: IfNoneMatch, location: "header", location_name: "If-None-Match"))
    HeadObjectRequest.add_member(:if_unmodified_since, Shapes::ShapeRef.new(shape: IfUnmodifiedSince, location: "header", location_name: "If-Unmodified-Since"))
    HeadObjectRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    HeadObjectRequest.add_member(:range, Shapes::ShapeRef.new(shape: Range, location: "header", location_name: "Range"))
    HeadObjectRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    HeadObjectRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    HeadObjectRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    HeadObjectRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    HeadObjectRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    HeadObjectRequest.add_member(:part_number, Shapes::ShapeRef.new(shape: PartNumber, location: "querystring", location_name: "partNumber"))
    HeadObjectRequest.struct_class = Types::HeadObjectRequest

    IndexDocument.add_member(:suffix, Shapes::ShapeRef.new(shape: Suffix, required: true, location_name: "Suffix"))
    IndexDocument.struct_class = Types::IndexDocument

    Initiator.add_member(:id, Shapes::ShapeRef.new(shape: ID, location_name: "ID"))
    Initiator.add_member(:display_name, Shapes::ShapeRef.new(shape: DisplayName, location_name: "DisplayName"))
    Initiator.struct_class = Types::Initiator

    InputSerialization.add_member(:csv, Shapes::ShapeRef.new(shape: CSVInput, location_name: "CSV"))
    InputSerialization.add_member(:compression_type, Shapes::ShapeRef.new(shape: CompressionType, location_name: "CompressionType"))
    InputSerialization.add_member(:json, Shapes::ShapeRef.new(shape: JSONInput, location_name: "JSON"))
    InputSerialization.struct_class = Types::InputSerialization

    InventoryConfiguration.add_member(:destination, Shapes::ShapeRef.new(shape: InventoryDestination, required: true, location_name: "Destination"))
    InventoryConfiguration.add_member(:is_enabled, Shapes::ShapeRef.new(shape: IsEnabled, required: true, location_name: "IsEnabled"))
    InventoryConfiguration.add_member(:filter, Shapes::ShapeRef.new(shape: InventoryFilter, location_name: "Filter"))
    InventoryConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: InventoryId, required: true, location_name: "Id"))
    InventoryConfiguration.add_member(:included_object_versions, Shapes::ShapeRef.new(shape: InventoryIncludedObjectVersions, required: true, location_name: "IncludedObjectVersions"))
    InventoryConfiguration.add_member(:optional_fields, Shapes::ShapeRef.new(shape: InventoryOptionalFields, location_name: "OptionalFields"))
    InventoryConfiguration.add_member(:schedule, Shapes::ShapeRef.new(shape: InventorySchedule, required: true, location_name: "Schedule"))
    InventoryConfiguration.struct_class = Types::InventoryConfiguration

    InventoryConfigurationList.member = Shapes::ShapeRef.new(shape: InventoryConfiguration)

    InventoryDestination.add_member(:s3_bucket_destination, Shapes::ShapeRef.new(shape: InventoryS3BucketDestination, required: true, location_name: "S3BucketDestination"))
    InventoryDestination.struct_class = Types::InventoryDestination

    InventoryEncryption.add_member(:sses3, Shapes::ShapeRef.new(shape: SSES3, location_name: "SSE-S3"))
    InventoryEncryption.add_member(:ssekms, Shapes::ShapeRef.new(shape: SSEKMS, location_name: "SSE-KMS"))
    InventoryEncryption.struct_class = Types::InventoryEncryption

    InventoryFilter.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, required: true, location_name: "Prefix"))
    InventoryFilter.struct_class = Types::InventoryFilter

    InventoryOptionalFields.member = Shapes::ShapeRef.new(shape: InventoryOptionalField, location_name: "Field")

    InventoryS3BucketDestination.add_member(:account_id, Shapes::ShapeRef.new(shape: AccountId, location_name: "AccountId"))
    InventoryS3BucketDestination.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location_name: "Bucket"))
    InventoryS3BucketDestination.add_member(:format, Shapes::ShapeRef.new(shape: InventoryFormat, required: true, location_name: "Format"))
    InventoryS3BucketDestination.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    InventoryS3BucketDestination.add_member(:encryption, Shapes::ShapeRef.new(shape: InventoryEncryption, location_name: "Encryption"))
    InventoryS3BucketDestination.struct_class = Types::InventoryS3BucketDestination

    InventorySchedule.add_member(:frequency, Shapes::ShapeRef.new(shape: InventoryFrequency, required: true, location_name: "Frequency"))
    InventorySchedule.struct_class = Types::InventorySchedule

    JSONInput.add_member(:type, Shapes::ShapeRef.new(shape: JSONType, location_name: "Type"))
    JSONInput.struct_class = Types::JSONInput

    JSONOutput.add_member(:record_delimiter, Shapes::ShapeRef.new(shape: RecordDelimiter, location_name: "RecordDelimiter"))
    JSONOutput.struct_class = Types::JSONOutput

    LambdaFunctionConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: NotificationId, location_name: "Id"))
    LambdaFunctionConfiguration.add_member(:lambda_function_arn, Shapes::ShapeRef.new(shape: LambdaFunctionArn, required: true, location_name: "CloudFunction"))
    LambdaFunctionConfiguration.add_member(:events, Shapes::ShapeRef.new(shape: EventList, required: true, location_name: "Event"))
    LambdaFunctionConfiguration.add_member(:filter, Shapes::ShapeRef.new(shape: NotificationConfigurationFilter, location_name: "Filter"))
    LambdaFunctionConfiguration.struct_class = Types::LambdaFunctionConfiguration

    LambdaFunctionConfigurationList.member = Shapes::ShapeRef.new(shape: LambdaFunctionConfiguration)

    LifecycleConfiguration.add_member(:rules, Shapes::ShapeRef.new(shape: Rules, required: true, location_name: "Rule"))
    LifecycleConfiguration.struct_class = Types::LifecycleConfiguration

    LifecycleExpiration.add_member(:date, Shapes::ShapeRef.new(shape: Date, location_name: "Date"))
    LifecycleExpiration.add_member(:days, Shapes::ShapeRef.new(shape: Days, location_name: "Days"))
    LifecycleExpiration.add_member(:expired_object_delete_marker, Shapes::ShapeRef.new(shape: ExpiredObjectDeleteMarker, location_name: "ExpiredObjectDeleteMarker"))
    LifecycleExpiration.struct_class = Types::LifecycleExpiration

    LifecycleRule.add_member(:expiration, Shapes::ShapeRef.new(shape: LifecycleExpiration, location_name: "Expiration"))
    LifecycleRule.add_member(:id, Shapes::ShapeRef.new(shape: ID, location_name: "ID"))
    LifecycleRule.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, deprecated: true, location_name: "Prefix"))
    LifecycleRule.add_member(:filter, Shapes::ShapeRef.new(shape: LifecycleRuleFilter, location_name: "Filter"))
    LifecycleRule.add_member(:status, Shapes::ShapeRef.new(shape: ExpirationStatus, required: true, location_name: "Status"))
    LifecycleRule.add_member(:transitions, Shapes::ShapeRef.new(shape: TransitionList, location_name: "Transition"))
    LifecycleRule.add_member(:noncurrent_version_transitions, Shapes::ShapeRef.new(shape: NoncurrentVersionTransitionList, location_name: "NoncurrentVersionTransition"))
    LifecycleRule.add_member(:noncurrent_version_expiration, Shapes::ShapeRef.new(shape: NoncurrentVersionExpiration, location_name: "NoncurrentVersionExpiration"))
    LifecycleRule.add_member(:abort_incomplete_multipart_upload, Shapes::ShapeRef.new(shape: AbortIncompleteMultipartUpload, location_name: "AbortIncompleteMultipartUpload"))
    LifecycleRule.struct_class = Types::LifecycleRule

    LifecycleRuleAndOperator.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    LifecycleRuleAndOperator.add_member(:tags, Shapes::ShapeRef.new(shape: TagSet, location_name: "Tag", metadata: {"flattened"=>true}))
    LifecycleRuleAndOperator.struct_class = Types::LifecycleRuleAndOperator

    LifecycleRuleFilter.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    LifecycleRuleFilter.add_member(:tag, Shapes::ShapeRef.new(shape: Tag, location_name: "Tag"))
    LifecycleRuleFilter.add_member(:and, Shapes::ShapeRef.new(shape: LifecycleRuleAndOperator, location_name: "And"))
    LifecycleRuleFilter.struct_class = Types::LifecycleRuleFilter

    LifecycleRules.member = Shapes::ShapeRef.new(shape: LifecycleRule)

    ListBucketAnalyticsConfigurationsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListBucketAnalyticsConfigurationsOutput.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location_name: "ContinuationToken"))
    ListBucketAnalyticsConfigurationsOutput.add_member(:next_continuation_token, Shapes::ShapeRef.new(shape: NextToken, location_name: "NextContinuationToken"))
    ListBucketAnalyticsConfigurationsOutput.add_member(:analytics_configuration_list, Shapes::ShapeRef.new(shape: AnalyticsConfigurationList, location_name: "AnalyticsConfiguration"))
    ListBucketAnalyticsConfigurationsOutput.struct_class = Types::ListBucketAnalyticsConfigurationsOutput

    ListBucketAnalyticsConfigurationsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListBucketAnalyticsConfigurationsRequest.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location: "querystring", location_name: "continuation-token"))
    ListBucketAnalyticsConfigurationsRequest.struct_class = Types::ListBucketAnalyticsConfigurationsRequest

    ListBucketInventoryConfigurationsOutput.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location_name: "ContinuationToken"))
    ListBucketInventoryConfigurationsOutput.add_member(:inventory_configuration_list, Shapes::ShapeRef.new(shape: InventoryConfigurationList, location_name: "InventoryConfiguration"))
    ListBucketInventoryConfigurationsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListBucketInventoryConfigurationsOutput.add_member(:next_continuation_token, Shapes::ShapeRef.new(shape: NextToken, location_name: "NextContinuationToken"))
    ListBucketInventoryConfigurationsOutput.struct_class = Types::ListBucketInventoryConfigurationsOutput

    ListBucketInventoryConfigurationsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListBucketInventoryConfigurationsRequest.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location: "querystring", location_name: "continuation-token"))
    ListBucketInventoryConfigurationsRequest.struct_class = Types::ListBucketInventoryConfigurationsRequest

    ListBucketMetricsConfigurationsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListBucketMetricsConfigurationsOutput.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location_name: "ContinuationToken"))
    ListBucketMetricsConfigurationsOutput.add_member(:next_continuation_token, Shapes::ShapeRef.new(shape: NextToken, location_name: "NextContinuationToken"))
    ListBucketMetricsConfigurationsOutput.add_member(:metrics_configuration_list, Shapes::ShapeRef.new(shape: MetricsConfigurationList, location_name: "MetricsConfiguration"))
    ListBucketMetricsConfigurationsOutput.struct_class = Types::ListBucketMetricsConfigurationsOutput

    ListBucketMetricsConfigurationsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListBucketMetricsConfigurationsRequest.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location: "querystring", location_name: "continuation-token"))
    ListBucketMetricsConfigurationsRequest.struct_class = Types::ListBucketMetricsConfigurationsRequest

    ListBucketsOutput.add_member(:buckets, Shapes::ShapeRef.new(shape: Buckets, location_name: "Buckets"))
    ListBucketsOutput.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    ListBucketsOutput.struct_class = Types::ListBucketsOutput

    ListMultipartUploadsOutput.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, location_name: "Bucket"))
    ListMultipartUploadsOutput.add_member(:key_marker, Shapes::ShapeRef.new(shape: KeyMarker, location_name: "KeyMarker"))
    ListMultipartUploadsOutput.add_member(:upload_id_marker, Shapes::ShapeRef.new(shape: UploadIdMarker, location_name: "UploadIdMarker"))
    ListMultipartUploadsOutput.add_member(:next_key_marker, Shapes::ShapeRef.new(shape: NextKeyMarker, location_name: "NextKeyMarker"))
    ListMultipartUploadsOutput.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    ListMultipartUploadsOutput.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location_name: "Delimiter"))
    ListMultipartUploadsOutput.add_member(:next_upload_id_marker, Shapes::ShapeRef.new(shape: NextUploadIdMarker, location_name: "NextUploadIdMarker"))
    ListMultipartUploadsOutput.add_member(:max_uploads, Shapes::ShapeRef.new(shape: MaxUploads, location_name: "MaxUploads"))
    ListMultipartUploadsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListMultipartUploadsOutput.add_member(:uploads, Shapes::ShapeRef.new(shape: MultipartUploadList, location_name: "Upload"))
    ListMultipartUploadsOutput.add_member(:common_prefixes, Shapes::ShapeRef.new(shape: CommonPrefixList, location_name: "CommonPrefixes"))
    ListMultipartUploadsOutput.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location_name: "EncodingType"))
    ListMultipartUploadsOutput.struct_class = Types::ListMultipartUploadsOutput

    ListMultipartUploadsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListMultipartUploadsRequest.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location: "querystring", location_name: "delimiter"))
    ListMultipartUploadsRequest.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location: "querystring", location_name: "encoding-type"))
    ListMultipartUploadsRequest.add_member(:key_marker, Shapes::ShapeRef.new(shape: KeyMarker, location: "querystring", location_name: "key-marker"))
    ListMultipartUploadsRequest.add_member(:max_uploads, Shapes::ShapeRef.new(shape: MaxUploads, location: "querystring", location_name: "max-uploads"))
    ListMultipartUploadsRequest.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location: "querystring", location_name: "prefix"))
    ListMultipartUploadsRequest.add_member(:upload_id_marker, Shapes::ShapeRef.new(shape: UploadIdMarker, location: "querystring", location_name: "upload-id-marker"))
    ListMultipartUploadsRequest.struct_class = Types::ListMultipartUploadsRequest

    ListObjectVersionsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListObjectVersionsOutput.add_member(:key_marker, Shapes::ShapeRef.new(shape: KeyMarker, location_name: "KeyMarker"))
    ListObjectVersionsOutput.add_member(:version_id_marker, Shapes::ShapeRef.new(shape: VersionIdMarker, location_name: "VersionIdMarker"))
    ListObjectVersionsOutput.add_member(:next_key_marker, Shapes::ShapeRef.new(shape: NextKeyMarker, location_name: "NextKeyMarker"))
    ListObjectVersionsOutput.add_member(:next_version_id_marker, Shapes::ShapeRef.new(shape: NextVersionIdMarker, location_name: "NextVersionIdMarker"))
    ListObjectVersionsOutput.add_member(:versions, Shapes::ShapeRef.new(shape: ObjectVersionList, location_name: "Version"))
    ListObjectVersionsOutput.add_member(:delete_markers, Shapes::ShapeRef.new(shape: DeleteMarkers, location_name: "DeleteMarker"))
    ListObjectVersionsOutput.add_member(:name, Shapes::ShapeRef.new(shape: BucketName, location_name: "Name"))
    ListObjectVersionsOutput.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    ListObjectVersionsOutput.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location_name: "Delimiter"))
    ListObjectVersionsOutput.add_member(:max_keys, Shapes::ShapeRef.new(shape: MaxKeys, location_name: "MaxKeys"))
    ListObjectVersionsOutput.add_member(:common_prefixes, Shapes::ShapeRef.new(shape: CommonPrefixList, location_name: "CommonPrefixes"))
    ListObjectVersionsOutput.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location_name: "EncodingType"))
    ListObjectVersionsOutput.struct_class = Types::ListObjectVersionsOutput

    ListObjectVersionsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListObjectVersionsRequest.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location: "querystring", location_name: "delimiter"))
    ListObjectVersionsRequest.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location: "querystring", location_name: "encoding-type"))
    ListObjectVersionsRequest.add_member(:key_marker, Shapes::ShapeRef.new(shape: KeyMarker, location: "querystring", location_name: "key-marker"))
    ListObjectVersionsRequest.add_member(:max_keys, Shapes::ShapeRef.new(shape: MaxKeys, location: "querystring", location_name: "max-keys"))
    ListObjectVersionsRequest.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location: "querystring", location_name: "prefix"))
    ListObjectVersionsRequest.add_member(:version_id_marker, Shapes::ShapeRef.new(shape: VersionIdMarker, location: "querystring", location_name: "version-id-marker"))
    ListObjectVersionsRequest.struct_class = Types::ListObjectVersionsRequest

    ListObjectsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListObjectsOutput.add_member(:marker, Shapes::ShapeRef.new(shape: Marker, location_name: "Marker"))
    ListObjectsOutput.add_member(:next_marker, Shapes::ShapeRef.new(shape: NextMarker, location_name: "NextMarker"))
    ListObjectsOutput.add_member(:contents, Shapes::ShapeRef.new(shape: ObjectList, location_name: "Contents"))
    ListObjectsOutput.add_member(:name, Shapes::ShapeRef.new(shape: BucketName, location_name: "Name"))
    ListObjectsOutput.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    ListObjectsOutput.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location_name: "Delimiter"))
    ListObjectsOutput.add_member(:max_keys, Shapes::ShapeRef.new(shape: MaxKeys, location_name: "MaxKeys"))
    ListObjectsOutput.add_member(:common_prefixes, Shapes::ShapeRef.new(shape: CommonPrefixList, location_name: "CommonPrefixes"))
    ListObjectsOutput.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location_name: "EncodingType"))
    ListObjectsOutput.struct_class = Types::ListObjectsOutput

    ListObjectsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListObjectsRequest.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location: "querystring", location_name: "delimiter"))
    ListObjectsRequest.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location: "querystring", location_name: "encoding-type"))
    ListObjectsRequest.add_member(:marker, Shapes::ShapeRef.new(shape: Marker, location: "querystring", location_name: "marker"))
    ListObjectsRequest.add_member(:max_keys, Shapes::ShapeRef.new(shape: MaxKeys, location: "querystring", location_name: "max-keys"))
    ListObjectsRequest.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location: "querystring", location_name: "prefix"))
    ListObjectsRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    ListObjectsRequest.struct_class = Types::ListObjectsRequest

    ListObjectsV2Output.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListObjectsV2Output.add_member(:contents, Shapes::ShapeRef.new(shape: ObjectList, location_name: "Contents"))
    ListObjectsV2Output.add_member(:name, Shapes::ShapeRef.new(shape: BucketName, location_name: "Name"))
    ListObjectsV2Output.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    ListObjectsV2Output.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location_name: "Delimiter"))
    ListObjectsV2Output.add_member(:max_keys, Shapes::ShapeRef.new(shape: MaxKeys, location_name: "MaxKeys"))
    ListObjectsV2Output.add_member(:common_prefixes, Shapes::ShapeRef.new(shape: CommonPrefixList, location_name: "CommonPrefixes"))
    ListObjectsV2Output.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location_name: "EncodingType"))
    ListObjectsV2Output.add_member(:key_count, Shapes::ShapeRef.new(shape: KeyCount, location_name: "KeyCount"))
    ListObjectsV2Output.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location_name: "ContinuationToken"))
    ListObjectsV2Output.add_member(:next_continuation_token, Shapes::ShapeRef.new(shape: NextToken, location_name: "NextContinuationToken"))
    ListObjectsV2Output.add_member(:start_after, Shapes::ShapeRef.new(shape: StartAfter, location_name: "StartAfter"))
    ListObjectsV2Output.struct_class = Types::ListObjectsV2Output

    ListObjectsV2Request.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListObjectsV2Request.add_member(:delimiter, Shapes::ShapeRef.new(shape: Delimiter, location: "querystring", location_name: "delimiter"))
    ListObjectsV2Request.add_member(:encoding_type, Shapes::ShapeRef.new(shape: EncodingType, location: "querystring", location_name: "encoding-type"))
    ListObjectsV2Request.add_member(:max_keys, Shapes::ShapeRef.new(shape: MaxKeys, location: "querystring", location_name: "max-keys"))
    ListObjectsV2Request.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location: "querystring", location_name: "prefix"))
    ListObjectsV2Request.add_member(:continuation_token, Shapes::ShapeRef.new(shape: Token, location: "querystring", location_name: "continuation-token"))
    ListObjectsV2Request.add_member(:fetch_owner, Shapes::ShapeRef.new(shape: FetchOwner, location: "querystring", location_name: "fetch-owner"))
    ListObjectsV2Request.add_member(:start_after, Shapes::ShapeRef.new(shape: StartAfter, location: "querystring", location_name: "start-after"))
    ListObjectsV2Request.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    ListObjectsV2Request.struct_class = Types::ListObjectsV2Request

    ListPartsOutput.add_member(:abort_date, Shapes::ShapeRef.new(shape: AbortDate, location: "header", location_name: "x-amz-abort-date"))
    ListPartsOutput.add_member(:abort_rule_id, Shapes::ShapeRef.new(shape: AbortRuleId, location: "header", location_name: "x-amz-abort-rule-id"))
    ListPartsOutput.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, location_name: "Bucket"))
    ListPartsOutput.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    ListPartsOutput.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, location_name: "UploadId"))
    ListPartsOutput.add_member(:part_number_marker, Shapes::ShapeRef.new(shape: PartNumberMarker, location_name: "PartNumberMarker"))
    ListPartsOutput.add_member(:next_part_number_marker, Shapes::ShapeRef.new(shape: NextPartNumberMarker, location_name: "NextPartNumberMarker"))
    ListPartsOutput.add_member(:max_parts, Shapes::ShapeRef.new(shape: MaxParts, location_name: "MaxParts"))
    ListPartsOutput.add_member(:is_truncated, Shapes::ShapeRef.new(shape: IsTruncated, location_name: "IsTruncated"))
    ListPartsOutput.add_member(:parts, Shapes::ShapeRef.new(shape: Parts, location_name: "Part"))
    ListPartsOutput.add_member(:initiator, Shapes::ShapeRef.new(shape: Initiator, location_name: "Initiator"))
    ListPartsOutput.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    ListPartsOutput.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location_name: "StorageClass"))
    ListPartsOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    ListPartsOutput.struct_class = Types::ListPartsOutput

    ListPartsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    ListPartsRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    ListPartsRequest.add_member(:max_parts, Shapes::ShapeRef.new(shape: MaxParts, location: "querystring", location_name: "max-parts"))
    ListPartsRequest.add_member(:part_number_marker, Shapes::ShapeRef.new(shape: PartNumberMarker, location: "querystring", location_name: "part-number-marker"))
    ListPartsRequest.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, required: true, location: "querystring", location_name: "uploadId"))
    ListPartsRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    ListPartsRequest.struct_class = Types::ListPartsRequest

    LoggingEnabled.add_member(:target_bucket, Shapes::ShapeRef.new(shape: TargetBucket, required: true, location_name: "TargetBucket"))
    LoggingEnabled.add_member(:target_grants, Shapes::ShapeRef.new(shape: TargetGrants, location_name: "TargetGrants"))
    LoggingEnabled.add_member(:target_prefix, Shapes::ShapeRef.new(shape: TargetPrefix, required: true, location_name: "TargetPrefix"))
    LoggingEnabled.struct_class = Types::LoggingEnabled

    Metadata.key = Shapes::ShapeRef.new(shape: MetadataKey)
    Metadata.value = Shapes::ShapeRef.new(shape: MetadataValue)

    MetadataEntry.add_member(:name, Shapes::ShapeRef.new(shape: MetadataKey, location_name: "Name"))
    MetadataEntry.add_member(:value, Shapes::ShapeRef.new(shape: MetadataValue, location_name: "Value"))
    MetadataEntry.struct_class = Types::MetadataEntry

    MetricsAndOperator.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    MetricsAndOperator.add_member(:tags, Shapes::ShapeRef.new(shape: TagSet, location_name: "Tag", metadata: {"flattened"=>true}))
    MetricsAndOperator.struct_class = Types::MetricsAndOperator

    MetricsConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: MetricsId, required: true, location_name: "Id"))
    MetricsConfiguration.add_member(:filter, Shapes::ShapeRef.new(shape: MetricsFilter, location_name: "Filter"))
    MetricsConfiguration.struct_class = Types::MetricsConfiguration

    MetricsConfigurationList.member = Shapes::ShapeRef.new(shape: MetricsConfiguration)

    MetricsFilter.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, location_name: "Prefix"))
    MetricsFilter.add_member(:tag, Shapes::ShapeRef.new(shape: Tag, location_name: "Tag"))
    MetricsFilter.add_member(:and, Shapes::ShapeRef.new(shape: MetricsAndOperator, location_name: "And"))
    MetricsFilter.struct_class = Types::MetricsFilter

    MultipartUpload.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, location_name: "UploadId"))
    MultipartUpload.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    MultipartUpload.add_member(:initiated, Shapes::ShapeRef.new(shape: Initiated, location_name: "Initiated"))
    MultipartUpload.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location_name: "StorageClass"))
    MultipartUpload.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    MultipartUpload.add_member(:initiator, Shapes::ShapeRef.new(shape: Initiator, location_name: "Initiator"))
    MultipartUpload.struct_class = Types::MultipartUpload

    MultipartUploadList.member = Shapes::ShapeRef.new(shape: MultipartUpload)

    NoncurrentVersionExpiration.add_member(:noncurrent_days, Shapes::ShapeRef.new(shape: Days, location_name: "NoncurrentDays"))
    NoncurrentVersionExpiration.struct_class = Types::NoncurrentVersionExpiration

    NoncurrentVersionTransition.add_member(:noncurrent_days, Shapes::ShapeRef.new(shape: Days, location_name: "NoncurrentDays"))
    NoncurrentVersionTransition.add_member(:storage_class, Shapes::ShapeRef.new(shape: TransitionStorageClass, location_name: "StorageClass"))
    NoncurrentVersionTransition.struct_class = Types::NoncurrentVersionTransition

    NoncurrentVersionTransitionList.member = Shapes::ShapeRef.new(shape: NoncurrentVersionTransition)

    NotificationConfiguration.add_member(:topic_configurations, Shapes::ShapeRef.new(shape: TopicConfigurationList, location_name: "TopicConfiguration"))
    NotificationConfiguration.add_member(:queue_configurations, Shapes::ShapeRef.new(shape: QueueConfigurationList, location_name: "QueueConfiguration"))
    NotificationConfiguration.add_member(:lambda_function_configurations, Shapes::ShapeRef.new(shape: LambdaFunctionConfigurationList, location_name: "CloudFunctionConfiguration"))
    NotificationConfiguration.struct_class = Types::NotificationConfiguration

    NotificationConfigurationDeprecated.add_member(:topic_configuration, Shapes::ShapeRef.new(shape: TopicConfigurationDeprecated, location_name: "TopicConfiguration"))
    NotificationConfigurationDeprecated.add_member(:queue_configuration, Shapes::ShapeRef.new(shape: QueueConfigurationDeprecated, location_name: "QueueConfiguration"))
    NotificationConfigurationDeprecated.add_member(:cloud_function_configuration, Shapes::ShapeRef.new(shape: CloudFunctionConfiguration, location_name: "CloudFunctionConfiguration"))
    NotificationConfigurationDeprecated.struct_class = Types::NotificationConfigurationDeprecated

    NotificationConfigurationFilter.add_member(:key, Shapes::ShapeRef.new(shape: S3KeyFilter, location_name: "S3Key"))
    NotificationConfigurationFilter.struct_class = Types::NotificationConfigurationFilter

    Object.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    Object.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location_name: "LastModified"))
    Object.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    Object.add_member(:size, Shapes::ShapeRef.new(shape: Size, location_name: "Size"))
    Object.add_member(:storage_class, Shapes::ShapeRef.new(shape: ObjectStorageClass, location_name: "StorageClass"))
    Object.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    Object.struct_class = Types::Object

    ObjectIdentifier.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location_name: "Key"))
    ObjectIdentifier.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location_name: "VersionId"))
    ObjectIdentifier.struct_class = Types::ObjectIdentifier

    ObjectIdentifierList.member = Shapes::ShapeRef.new(shape: ObjectIdentifier)

    ObjectList.member = Shapes::ShapeRef.new(shape: Object)

    ObjectVersion.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    ObjectVersion.add_member(:size, Shapes::ShapeRef.new(shape: Size, location_name: "Size"))
    ObjectVersion.add_member(:storage_class, Shapes::ShapeRef.new(shape: ObjectVersionStorageClass, location_name: "StorageClass"))
    ObjectVersion.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, location_name: "Key"))
    ObjectVersion.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location_name: "VersionId"))
    ObjectVersion.add_member(:is_latest, Shapes::ShapeRef.new(shape: IsLatest, location_name: "IsLatest"))
    ObjectVersion.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location_name: "LastModified"))
    ObjectVersion.add_member(:owner, Shapes::ShapeRef.new(shape: Owner, location_name: "Owner"))
    ObjectVersion.struct_class = Types::ObjectVersion

    ObjectVersionList.member = Shapes::ShapeRef.new(shape: ObjectVersion)

    OutputLocation.add_member(:s3, Shapes::ShapeRef.new(shape: S3Location, location_name: "S3"))
    OutputLocation.struct_class = Types::OutputLocation

    OutputSerialization.add_member(:csv, Shapes::ShapeRef.new(shape: CSVOutput, location_name: "CSV"))
    OutputSerialization.add_member(:json, Shapes::ShapeRef.new(shape: JSONOutput, location_name: "JSON"))
    OutputSerialization.struct_class = Types::OutputSerialization

    Owner.add_member(:display_name, Shapes::ShapeRef.new(shape: DisplayName, location_name: "DisplayName"))
    Owner.add_member(:id, Shapes::ShapeRef.new(shape: ID, location_name: "ID"))
    Owner.struct_class = Types::Owner

    Part.add_member(:part_number, Shapes::ShapeRef.new(shape: PartNumber, location_name: "PartNumber"))
    Part.add_member(:last_modified, Shapes::ShapeRef.new(shape: LastModified, location_name: "LastModified"))
    Part.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location_name: "ETag"))
    Part.add_member(:size, Shapes::ShapeRef.new(shape: Size, location_name: "Size"))
    Part.struct_class = Types::Part

    Parts.member = Shapes::ShapeRef.new(shape: Part)

    Progress.add_member(:bytes_scanned, Shapes::ShapeRef.new(shape: BytesScanned, location_name: "BytesScanned"))
    Progress.add_member(:bytes_processed, Shapes::ShapeRef.new(shape: BytesProcessed, location_name: "BytesProcessed"))
    Progress.struct_class = Types::Progress

    PutBucketAccelerateConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketAccelerateConfigurationRequest.add_member(:accelerate_configuration, Shapes::ShapeRef.new(shape: AccelerateConfiguration, required: true, location_name: "AccelerateConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketAccelerateConfigurationRequest.struct_class = Types::PutBucketAccelerateConfigurationRequest
    PutBucketAccelerateConfigurationRequest[:payload] = :accelerate_configuration
    PutBucketAccelerateConfigurationRequest[:payload_member] = PutBucketAccelerateConfigurationRequest.member(:accelerate_configuration)

    PutBucketAclRequest.add_member(:acl, Shapes::ShapeRef.new(shape: BucketCannedACL, location: "header", location_name: "x-amz-acl"))
    PutBucketAclRequest.add_member(:access_control_policy, Shapes::ShapeRef.new(shape: AccessControlPolicy, location_name: "AccessControlPolicy", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketAclRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketAclRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketAclRequest.add_member(:grant_full_control, Shapes::ShapeRef.new(shape: GrantFullControl, location: "header", location_name: "x-amz-grant-full-control"))
    PutBucketAclRequest.add_member(:grant_read, Shapes::ShapeRef.new(shape: GrantRead, location: "header", location_name: "x-amz-grant-read"))
    PutBucketAclRequest.add_member(:grant_read_acp, Shapes::ShapeRef.new(shape: GrantReadACP, location: "header", location_name: "x-amz-grant-read-acp"))
    PutBucketAclRequest.add_member(:grant_write, Shapes::ShapeRef.new(shape: GrantWrite, location: "header", location_name: "x-amz-grant-write"))
    PutBucketAclRequest.add_member(:grant_write_acp, Shapes::ShapeRef.new(shape: GrantWriteACP, location: "header", location_name: "x-amz-grant-write-acp"))
    PutBucketAclRequest.struct_class = Types::PutBucketAclRequest
    PutBucketAclRequest[:payload] = :access_control_policy
    PutBucketAclRequest[:payload_member] = PutBucketAclRequest.member(:access_control_policy)

    PutBucketAnalyticsConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketAnalyticsConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: AnalyticsId, required: true, location: "querystring", location_name: "id"))
    PutBucketAnalyticsConfigurationRequest.add_member(:analytics_configuration, Shapes::ShapeRef.new(shape: AnalyticsConfiguration, required: true, location_name: "AnalyticsConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketAnalyticsConfigurationRequest.struct_class = Types::PutBucketAnalyticsConfigurationRequest
    PutBucketAnalyticsConfigurationRequest[:payload] = :analytics_configuration
    PutBucketAnalyticsConfigurationRequest[:payload_member] = PutBucketAnalyticsConfigurationRequest.member(:analytics_configuration)

    PutBucketCorsRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketCorsRequest.add_member(:cors_configuration, Shapes::ShapeRef.new(shape: CORSConfiguration, required: true, location_name: "CORSConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketCorsRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketCorsRequest.struct_class = Types::PutBucketCorsRequest
    PutBucketCorsRequest[:payload] = :cors_configuration
    PutBucketCorsRequest[:payload_member] = PutBucketCorsRequest.member(:cors_configuration)

    PutBucketEncryptionRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketEncryptionRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketEncryptionRequest.add_member(:server_side_encryption_configuration, Shapes::ShapeRef.new(shape: ServerSideEncryptionConfiguration, required: true, location_name: "ServerSideEncryptionConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketEncryptionRequest.struct_class = Types::PutBucketEncryptionRequest
    PutBucketEncryptionRequest[:payload] = :server_side_encryption_configuration
    PutBucketEncryptionRequest[:payload_member] = PutBucketEncryptionRequest.member(:server_side_encryption_configuration)

    PutBucketInventoryConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketInventoryConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: InventoryId, required: true, location: "querystring", location_name: "id"))
    PutBucketInventoryConfigurationRequest.add_member(:inventory_configuration, Shapes::ShapeRef.new(shape: InventoryConfiguration, required: true, location_name: "InventoryConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketInventoryConfigurationRequest.struct_class = Types::PutBucketInventoryConfigurationRequest
    PutBucketInventoryConfigurationRequest[:payload] = :inventory_configuration
    PutBucketInventoryConfigurationRequest[:payload_member] = PutBucketInventoryConfigurationRequest.member(:inventory_configuration)

    PutBucketLifecycleConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketLifecycleConfigurationRequest.add_member(:lifecycle_configuration, Shapes::ShapeRef.new(shape: BucketLifecycleConfiguration, location_name: "LifecycleConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketLifecycleConfigurationRequest.struct_class = Types::PutBucketLifecycleConfigurationRequest
    PutBucketLifecycleConfigurationRequest[:payload] = :lifecycle_configuration
    PutBucketLifecycleConfigurationRequest[:payload_member] = PutBucketLifecycleConfigurationRequest.member(:lifecycle_configuration)

    PutBucketLifecycleRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketLifecycleRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketLifecycleRequest.add_member(:lifecycle_configuration, Shapes::ShapeRef.new(shape: LifecycleConfiguration, location_name: "LifecycleConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketLifecycleRequest.struct_class = Types::PutBucketLifecycleRequest
    PutBucketLifecycleRequest[:payload] = :lifecycle_configuration
    PutBucketLifecycleRequest[:payload_member] = PutBucketLifecycleRequest.member(:lifecycle_configuration)

    PutBucketLoggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketLoggingRequest.add_member(:bucket_logging_status, Shapes::ShapeRef.new(shape: BucketLoggingStatus, required: true, location_name: "BucketLoggingStatus", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketLoggingRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketLoggingRequest.struct_class = Types::PutBucketLoggingRequest
    PutBucketLoggingRequest[:payload] = :bucket_logging_status
    PutBucketLoggingRequest[:payload_member] = PutBucketLoggingRequest.member(:bucket_logging_status)

    PutBucketMetricsConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketMetricsConfigurationRequest.add_member(:id, Shapes::ShapeRef.new(shape: MetricsId, required: true, location: "querystring", location_name: "id"))
    PutBucketMetricsConfigurationRequest.add_member(:metrics_configuration, Shapes::ShapeRef.new(shape: MetricsConfiguration, required: true, location_name: "MetricsConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketMetricsConfigurationRequest.struct_class = Types::PutBucketMetricsConfigurationRequest
    PutBucketMetricsConfigurationRequest[:payload] = :metrics_configuration
    PutBucketMetricsConfigurationRequest[:payload_member] = PutBucketMetricsConfigurationRequest.member(:metrics_configuration)

    PutBucketNotificationConfigurationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketNotificationConfigurationRequest.add_member(:notification_configuration, Shapes::ShapeRef.new(shape: NotificationConfiguration, required: true, location_name: "NotificationConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketNotificationConfigurationRequest.struct_class = Types::PutBucketNotificationConfigurationRequest
    PutBucketNotificationConfigurationRequest[:payload] = :notification_configuration
    PutBucketNotificationConfigurationRequest[:payload_member] = PutBucketNotificationConfigurationRequest.member(:notification_configuration)

    PutBucketNotificationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketNotificationRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketNotificationRequest.add_member(:notification_configuration, Shapes::ShapeRef.new(shape: NotificationConfigurationDeprecated, required: true, location_name: "NotificationConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketNotificationRequest.struct_class = Types::PutBucketNotificationRequest
    PutBucketNotificationRequest[:payload] = :notification_configuration
    PutBucketNotificationRequest[:payload_member] = PutBucketNotificationRequest.member(:notification_configuration)

    PutBucketPolicyRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketPolicyRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketPolicyRequest.add_member(:confirm_remove_self_bucket_access, Shapes::ShapeRef.new(shape: ConfirmRemoveSelfBucketAccess, location: "header", location_name: "x-amz-confirm-remove-self-bucket-access"))
    PutBucketPolicyRequest.add_member(:policy, Shapes::ShapeRef.new(shape: Policy, required: true, location_name: "Policy"))
    PutBucketPolicyRequest.struct_class = Types::PutBucketPolicyRequest
    PutBucketPolicyRequest[:payload] = :policy
    PutBucketPolicyRequest[:payload_member] = PutBucketPolicyRequest.member(:policy)

    PutBucketReplicationRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketReplicationRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketReplicationRequest.add_member(:replication_configuration, Shapes::ShapeRef.new(shape: ReplicationConfiguration, required: true, location_name: "ReplicationConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketReplicationRequest.struct_class = Types::PutBucketReplicationRequest
    PutBucketReplicationRequest[:payload] = :replication_configuration
    PutBucketReplicationRequest[:payload_member] = PutBucketReplicationRequest.member(:replication_configuration)

    PutBucketRequestPaymentRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketRequestPaymentRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketRequestPaymentRequest.add_member(:request_payment_configuration, Shapes::ShapeRef.new(shape: RequestPaymentConfiguration, required: true, location_name: "RequestPaymentConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketRequestPaymentRequest.struct_class = Types::PutBucketRequestPaymentRequest
    PutBucketRequestPaymentRequest[:payload] = :request_payment_configuration
    PutBucketRequestPaymentRequest[:payload_member] = PutBucketRequestPaymentRequest.member(:request_payment_configuration)

    PutBucketTaggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketTaggingRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketTaggingRequest.add_member(:tagging, Shapes::ShapeRef.new(shape: Tagging, required: true, location_name: "Tagging", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketTaggingRequest.struct_class = Types::PutBucketTaggingRequest
    PutBucketTaggingRequest[:payload] = :tagging
    PutBucketTaggingRequest[:payload_member] = PutBucketTaggingRequest.member(:tagging)

    PutBucketVersioningRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketVersioningRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketVersioningRequest.add_member(:mfa, Shapes::ShapeRef.new(shape: MFA, location: "header", location_name: "x-amz-mfa"))
    PutBucketVersioningRequest.add_member(:versioning_configuration, Shapes::ShapeRef.new(shape: VersioningConfiguration, required: true, location_name: "VersioningConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketVersioningRequest.struct_class = Types::PutBucketVersioningRequest
    PutBucketVersioningRequest[:payload] = :versioning_configuration
    PutBucketVersioningRequest[:payload_member] = PutBucketVersioningRequest.member(:versioning_configuration)

    PutBucketWebsiteRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutBucketWebsiteRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutBucketWebsiteRequest.add_member(:website_configuration, Shapes::ShapeRef.new(shape: WebsiteConfiguration, required: true, location_name: "WebsiteConfiguration", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutBucketWebsiteRequest.struct_class = Types::PutBucketWebsiteRequest
    PutBucketWebsiteRequest[:payload] = :website_configuration
    PutBucketWebsiteRequest[:payload_member] = PutBucketWebsiteRequest.member(:website_configuration)

    PutObjectAclOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    PutObjectAclOutput.struct_class = Types::PutObjectAclOutput

    PutObjectAclRequest.add_member(:acl, Shapes::ShapeRef.new(shape: ObjectCannedACL, location: "header", location_name: "x-amz-acl"))
    PutObjectAclRequest.add_member(:access_control_policy, Shapes::ShapeRef.new(shape: AccessControlPolicy, location_name: "AccessControlPolicy", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutObjectAclRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutObjectAclRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutObjectAclRequest.add_member(:grant_full_control, Shapes::ShapeRef.new(shape: GrantFullControl, location: "header", location_name: "x-amz-grant-full-control"))
    PutObjectAclRequest.add_member(:grant_read, Shapes::ShapeRef.new(shape: GrantRead, location: "header", location_name: "x-amz-grant-read"))
    PutObjectAclRequest.add_member(:grant_read_acp, Shapes::ShapeRef.new(shape: GrantReadACP, location: "header", location_name: "x-amz-grant-read-acp"))
    PutObjectAclRequest.add_member(:grant_write, Shapes::ShapeRef.new(shape: GrantWrite, location: "header", location_name: "x-amz-grant-write"))
    PutObjectAclRequest.add_member(:grant_write_acp, Shapes::ShapeRef.new(shape: GrantWriteACP, location: "header", location_name: "x-amz-grant-write-acp"))
    PutObjectAclRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    PutObjectAclRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    PutObjectAclRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    PutObjectAclRequest.struct_class = Types::PutObjectAclRequest
    PutObjectAclRequest[:payload] = :access_control_policy
    PutObjectAclRequest[:payload_member] = PutObjectAclRequest.member(:access_control_policy)

    PutObjectOutput.add_member(:expiration, Shapes::ShapeRef.new(shape: Expiration, location: "header", location_name: "x-amz-expiration"))
    PutObjectOutput.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location: "header", location_name: "ETag"))
    PutObjectOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    PutObjectOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    PutObjectOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    PutObjectOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    PutObjectOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    PutObjectOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    PutObjectOutput.struct_class = Types::PutObjectOutput

    PutObjectRequest.add_member(:acl, Shapes::ShapeRef.new(shape: ObjectCannedACL, location: "header", location_name: "x-amz-acl"))
    PutObjectRequest.add_member(:body, Shapes::ShapeRef.new(shape: Body, location_name: "Body", metadata: {"streaming"=>true}))
    PutObjectRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutObjectRequest.add_member(:cache_control, Shapes::ShapeRef.new(shape: CacheControl, location: "header", location_name: "Cache-Control"))
    PutObjectRequest.add_member(:content_disposition, Shapes::ShapeRef.new(shape: ContentDisposition, location: "header", location_name: "Content-Disposition"))
    PutObjectRequest.add_member(:content_encoding, Shapes::ShapeRef.new(shape: ContentEncoding, location: "header", location_name: "Content-Encoding"))
    PutObjectRequest.add_member(:content_language, Shapes::ShapeRef.new(shape: ContentLanguage, location: "header", location_name: "Content-Language"))
    PutObjectRequest.add_member(:content_length, Shapes::ShapeRef.new(shape: ContentLength, location: "header", location_name: "Content-Length"))
    PutObjectRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutObjectRequest.add_member(:content_type, Shapes::ShapeRef.new(shape: ContentType, location: "header", location_name: "Content-Type"))
    PutObjectRequest.add_member(:expires, Shapes::ShapeRef.new(shape: Expires, location: "header", location_name: "Expires"))
    PutObjectRequest.add_member(:grant_full_control, Shapes::ShapeRef.new(shape: GrantFullControl, location: "header", location_name: "x-amz-grant-full-control"))
    PutObjectRequest.add_member(:grant_read, Shapes::ShapeRef.new(shape: GrantRead, location: "header", location_name: "x-amz-grant-read"))
    PutObjectRequest.add_member(:grant_read_acp, Shapes::ShapeRef.new(shape: GrantReadACP, location: "header", location_name: "x-amz-grant-read-acp"))
    PutObjectRequest.add_member(:grant_write_acp, Shapes::ShapeRef.new(shape: GrantWriteACP, location: "header", location_name: "x-amz-grant-write-acp"))
    PutObjectRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    PutObjectRequest.add_member(:metadata, Shapes::ShapeRef.new(shape: Metadata, location: "headers", location_name: "x-amz-meta-"))
    PutObjectRequest.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    PutObjectRequest.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location: "header", location_name: "x-amz-storage-class"))
    PutObjectRequest.add_member(:website_redirect_location, Shapes::ShapeRef.new(shape: WebsiteRedirectLocation, location: "header", location_name: "x-amz-website-redirect-location"))
    PutObjectRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    PutObjectRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    PutObjectRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    PutObjectRequest.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    PutObjectRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    PutObjectRequest.add_member(:tagging, Shapes::ShapeRef.new(shape: TaggingHeader, location: "header", location_name: "x-amz-tagging"))
    PutObjectRequest.struct_class = Types::PutObjectRequest
    PutObjectRequest[:payload] = :body
    PutObjectRequest[:payload_member] = PutObjectRequest.member(:body)

    PutObjectTaggingOutput.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "header", location_name: "x-amz-version-id"))
    PutObjectTaggingOutput.struct_class = Types::PutObjectTaggingOutput

    PutObjectTaggingRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    PutObjectTaggingRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    PutObjectTaggingRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    PutObjectTaggingRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    PutObjectTaggingRequest.add_member(:tagging, Shapes::ShapeRef.new(shape: Tagging, required: true, location_name: "Tagging", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    PutObjectTaggingRequest.struct_class = Types::PutObjectTaggingRequest
    PutObjectTaggingRequest[:payload] = :tagging
    PutObjectTaggingRequest[:payload_member] = PutObjectTaggingRequest.member(:tagging)

    QueueConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: NotificationId, location_name: "Id"))
    QueueConfiguration.add_member(:queue_arn, Shapes::ShapeRef.new(shape: QueueArn, required: true, location_name: "Queue"))
    QueueConfiguration.add_member(:events, Shapes::ShapeRef.new(shape: EventList, required: true, location_name: "Event"))
    QueueConfiguration.add_member(:filter, Shapes::ShapeRef.new(shape: NotificationConfigurationFilter, location_name: "Filter"))
    QueueConfiguration.struct_class = Types::QueueConfiguration

    QueueConfigurationDeprecated.add_member(:id, Shapes::ShapeRef.new(shape: NotificationId, location_name: "Id"))
    QueueConfigurationDeprecated.add_member(:event, Shapes::ShapeRef.new(shape: Event, deprecated: true, location_name: "Event"))
    QueueConfigurationDeprecated.add_member(:events, Shapes::ShapeRef.new(shape: EventList, location_name: "Event"))
    QueueConfigurationDeprecated.add_member(:queue, Shapes::ShapeRef.new(shape: QueueArn, location_name: "Queue"))
    QueueConfigurationDeprecated.struct_class = Types::QueueConfigurationDeprecated

    QueueConfigurationList.member = Shapes::ShapeRef.new(shape: QueueConfiguration)

    Redirect.add_member(:host_name, Shapes::ShapeRef.new(shape: HostName, location_name: "HostName"))
    Redirect.add_member(:http_redirect_code, Shapes::ShapeRef.new(shape: HttpRedirectCode, location_name: "HttpRedirectCode"))
    Redirect.add_member(:protocol, Shapes::ShapeRef.new(shape: Protocol, location_name: "Protocol"))
    Redirect.add_member(:replace_key_prefix_with, Shapes::ShapeRef.new(shape: ReplaceKeyPrefixWith, location_name: "ReplaceKeyPrefixWith"))
    Redirect.add_member(:replace_key_with, Shapes::ShapeRef.new(shape: ReplaceKeyWith, location_name: "ReplaceKeyWith"))
    Redirect.struct_class = Types::Redirect

    RedirectAllRequestsTo.add_member(:host_name, Shapes::ShapeRef.new(shape: HostName, required: true, location_name: "HostName"))
    RedirectAllRequestsTo.add_member(:protocol, Shapes::ShapeRef.new(shape: Protocol, location_name: "Protocol"))
    RedirectAllRequestsTo.struct_class = Types::RedirectAllRequestsTo

    ReplicationConfiguration.add_member(:role, Shapes::ShapeRef.new(shape: Role, required: true, location_name: "Role"))
    ReplicationConfiguration.add_member(:rules, Shapes::ShapeRef.new(shape: ReplicationRules, required: true, location_name: "Rule"))
    ReplicationConfiguration.struct_class = Types::ReplicationConfiguration

    ReplicationRule.add_member(:id, Shapes::ShapeRef.new(shape: ID, location_name: "ID"))
    ReplicationRule.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, required: true, location_name: "Prefix"))
    ReplicationRule.add_member(:status, Shapes::ShapeRef.new(shape: ReplicationRuleStatus, required: true, location_name: "Status"))
    ReplicationRule.add_member(:source_selection_criteria, Shapes::ShapeRef.new(shape: SourceSelectionCriteria, location_name: "SourceSelectionCriteria"))
    ReplicationRule.add_member(:destination, Shapes::ShapeRef.new(shape: Destination, required: true, location_name: "Destination"))
    ReplicationRule.struct_class = Types::ReplicationRule

    ReplicationRules.member = Shapes::ShapeRef.new(shape: ReplicationRule)

    RequestPaymentConfiguration.add_member(:payer, Shapes::ShapeRef.new(shape: Payer, required: true, location_name: "Payer"))
    RequestPaymentConfiguration.struct_class = Types::RequestPaymentConfiguration

    RequestProgress.add_member(:enabled, Shapes::ShapeRef.new(shape: EnableRequestProgress, location_name: "Enabled"))
    RequestProgress.struct_class = Types::RequestProgress

    RestoreObjectOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    RestoreObjectOutput.add_member(:restore_output_path, Shapes::ShapeRef.new(shape: RestoreOutputPath, location: "header", location_name: "x-amz-restore-output-path"))
    RestoreObjectOutput.struct_class = Types::RestoreObjectOutput

    RestoreObjectRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    RestoreObjectRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    RestoreObjectRequest.add_member(:version_id, Shapes::ShapeRef.new(shape: ObjectVersionId, location: "querystring", location_name: "versionId"))
    RestoreObjectRequest.add_member(:restore_request, Shapes::ShapeRef.new(shape: RestoreRequest, location_name: "RestoreRequest", metadata: {"xmlNamespace"=>{"uri"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}))
    RestoreObjectRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    RestoreObjectRequest.struct_class = Types::RestoreObjectRequest
    RestoreObjectRequest[:payload] = :restore_request
    RestoreObjectRequest[:payload_member] = RestoreObjectRequest.member(:restore_request)

    RestoreRequest.add_member(:days, Shapes::ShapeRef.new(shape: Days, location_name: "Days"))
    RestoreRequest.add_member(:glacier_job_parameters, Shapes::ShapeRef.new(shape: GlacierJobParameters, location_name: "GlacierJobParameters"))
    RestoreRequest.add_member(:type, Shapes::ShapeRef.new(shape: RestoreRequestType, location_name: "Type"))
    RestoreRequest.add_member(:tier, Shapes::ShapeRef.new(shape: Tier, location_name: "Tier"))
    RestoreRequest.add_member(:description, Shapes::ShapeRef.new(shape: Description, location_name: "Description"))
    RestoreRequest.add_member(:select_parameters, Shapes::ShapeRef.new(shape: SelectParameters, location_name: "SelectParameters"))
    RestoreRequest.add_member(:output_location, Shapes::ShapeRef.new(shape: OutputLocation, location_name: "OutputLocation"))
    RestoreRequest.struct_class = Types::RestoreRequest

    RoutingRule.add_member(:condition, Shapes::ShapeRef.new(shape: Condition, location_name: "Condition"))
    RoutingRule.add_member(:redirect, Shapes::ShapeRef.new(shape: Redirect, required: true, location_name: "Redirect"))
    RoutingRule.struct_class = Types::RoutingRule

    RoutingRules.member = Shapes::ShapeRef.new(shape: RoutingRule, location_name: "RoutingRule")

    Rule.add_member(:expiration, Shapes::ShapeRef.new(shape: LifecycleExpiration, location_name: "Expiration"))
    Rule.add_member(:id, Shapes::ShapeRef.new(shape: ID, location_name: "ID"))
    Rule.add_member(:prefix, Shapes::ShapeRef.new(shape: Prefix, required: true, location_name: "Prefix"))
    Rule.add_member(:status, Shapes::ShapeRef.new(shape: ExpirationStatus, required: true, location_name: "Status"))
    Rule.add_member(:transition, Shapes::ShapeRef.new(shape: Transition, location_name: "Transition"))
    Rule.add_member(:noncurrent_version_transition, Shapes::ShapeRef.new(shape: NoncurrentVersionTransition, location_name: "NoncurrentVersionTransition"))
    Rule.add_member(:noncurrent_version_expiration, Shapes::ShapeRef.new(shape: NoncurrentVersionExpiration, location_name: "NoncurrentVersionExpiration"))
    Rule.add_member(:abort_incomplete_multipart_upload, Shapes::ShapeRef.new(shape: AbortIncompleteMultipartUpload, location_name: "AbortIncompleteMultipartUpload"))
    Rule.struct_class = Types::Rule

    Rules.member = Shapes::ShapeRef.new(shape: Rule)

    S3KeyFilter.add_member(:filter_rules, Shapes::ShapeRef.new(shape: FilterRuleList, location_name: "FilterRule"))
    S3KeyFilter.struct_class = Types::S3KeyFilter

    S3Location.add_member(:bucket_name, Shapes::ShapeRef.new(shape: BucketName, required: true, location_name: "BucketName"))
    S3Location.add_member(:prefix, Shapes::ShapeRef.new(shape: LocationPrefix, required: true, location_name: "Prefix"))
    S3Location.add_member(:encryption, Shapes::ShapeRef.new(shape: Encryption, location_name: "Encryption"))
    S3Location.add_member(:canned_acl, Shapes::ShapeRef.new(shape: ObjectCannedACL, location_name: "CannedACL"))
    S3Location.add_member(:access_control_list, Shapes::ShapeRef.new(shape: Grants, location_name: "AccessControlList"))
    S3Location.add_member(:tagging, Shapes::ShapeRef.new(shape: Tagging, location_name: "Tagging"))
    S3Location.add_member(:user_metadata, Shapes::ShapeRef.new(shape: UserMetadata, location_name: "UserMetadata"))
    S3Location.add_member(:storage_class, Shapes::ShapeRef.new(shape: StorageClass, location_name: "StorageClass"))
    S3Location.struct_class = Types::S3Location

    SSEKMS.add_member(:key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, required: true, location_name: "KeyId"))
    SSEKMS.struct_class = Types::SSEKMS

    SSES3.struct_class = Types::SSES3

    SelectParameters.add_member(:input_serialization, Shapes::ShapeRef.new(shape: InputSerialization, required: true, location_name: "InputSerialization"))
    SelectParameters.add_member(:expression_type, Shapes::ShapeRef.new(shape: ExpressionType, required: true, location_name: "ExpressionType"))
    SelectParameters.add_member(:expression, Shapes::ShapeRef.new(shape: Expression, required: true, location_name: "Expression"))
    SelectParameters.add_member(:output_serialization, Shapes::ShapeRef.new(shape: OutputSerialization, required: true, location_name: "OutputSerialization"))
    SelectParameters.struct_class = Types::SelectParameters

    ServerSideEncryptionByDefault.add_member(:sse_algorithm, Shapes::ShapeRef.new(shape: ServerSideEncryption, required: true, location_name: "SSEAlgorithm"))
    ServerSideEncryptionByDefault.add_member(:kms_master_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location_name: "KMSMasterKeyID"))
    ServerSideEncryptionByDefault.struct_class = Types::ServerSideEncryptionByDefault

    ServerSideEncryptionConfiguration.add_member(:rules, Shapes::ShapeRef.new(shape: ServerSideEncryptionRules, required: true, location_name: "Rule"))
    ServerSideEncryptionConfiguration.struct_class = Types::ServerSideEncryptionConfiguration

    ServerSideEncryptionRule.add_member(:apply_server_side_encryption_by_default, Shapes::ShapeRef.new(shape: ServerSideEncryptionByDefault, location_name: "ApplyServerSideEncryptionByDefault"))
    ServerSideEncryptionRule.struct_class = Types::ServerSideEncryptionRule

    ServerSideEncryptionRules.member = Shapes::ShapeRef.new(shape: ServerSideEncryptionRule)

    SourceSelectionCriteria.add_member(:sse_kms_encrypted_objects, Shapes::ShapeRef.new(shape: SseKmsEncryptedObjects, location_name: "SseKmsEncryptedObjects"))
    SourceSelectionCriteria.struct_class = Types::SourceSelectionCriteria

    SseKmsEncryptedObjects.add_member(:status, Shapes::ShapeRef.new(shape: SseKmsEncryptedObjectsStatus, required: true, location_name: "Status"))
    SseKmsEncryptedObjects.struct_class = Types::SseKmsEncryptedObjects

    Stats.add_member(:bytes_scanned, Shapes::ShapeRef.new(shape: BytesScanned, location_name: "BytesScanned"))
    Stats.add_member(:bytes_processed, Shapes::ShapeRef.new(shape: BytesProcessed, location_name: "BytesProcessed"))
    Stats.struct_class = Types::Stats

    StorageClassAnalysis.add_member(:data_export, Shapes::ShapeRef.new(shape: StorageClassAnalysisDataExport, location_name: "DataExport"))
    StorageClassAnalysis.struct_class = Types::StorageClassAnalysis

    StorageClassAnalysisDataExport.add_member(:output_schema_version, Shapes::ShapeRef.new(shape: StorageClassAnalysisSchemaVersion, required: true, location_name: "OutputSchemaVersion"))
    StorageClassAnalysisDataExport.add_member(:destination, Shapes::ShapeRef.new(shape: AnalyticsExportDestination, required: true, location_name: "Destination"))
    StorageClassAnalysisDataExport.struct_class = Types::StorageClassAnalysisDataExport

    Tag.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location_name: "Key"))
    Tag.add_member(:value, Shapes::ShapeRef.new(shape: Value, required: true, location_name: "Value"))
    Tag.struct_class = Types::Tag

    TagSet.member = Shapes::ShapeRef.new(shape: Tag, location_name: "Tag")

    Tagging.add_member(:tag_set, Shapes::ShapeRef.new(shape: TagSet, required: true, location_name: "TagSet"))
    Tagging.struct_class = Types::Tagging

    TargetGrant.add_member(:grantee, Shapes::ShapeRef.new(shape: Grantee, location_name: "Grantee"))
    TargetGrant.add_member(:permission, Shapes::ShapeRef.new(shape: BucketLogsPermission, location_name: "Permission"))
    TargetGrant.struct_class = Types::TargetGrant

    TargetGrants.member = Shapes::ShapeRef.new(shape: TargetGrant, location_name: "Grant")

    TopicConfiguration.add_member(:id, Shapes::ShapeRef.new(shape: NotificationId, location_name: "Id"))
    TopicConfiguration.add_member(:topic_arn, Shapes::ShapeRef.new(shape: TopicArn, required: true, location_name: "Topic"))
    TopicConfiguration.add_member(:events, Shapes::ShapeRef.new(shape: EventList, required: true, location_name: "Event"))
    TopicConfiguration.add_member(:filter, Shapes::ShapeRef.new(shape: NotificationConfigurationFilter, location_name: "Filter"))
    TopicConfiguration.struct_class = Types::TopicConfiguration

    TopicConfigurationDeprecated.add_member(:id, Shapes::ShapeRef.new(shape: NotificationId, location_name: "Id"))
    TopicConfigurationDeprecated.add_member(:events, Shapes::ShapeRef.new(shape: EventList, location_name: "Event"))
    TopicConfigurationDeprecated.add_member(:event, Shapes::ShapeRef.new(shape: Event, deprecated: true, location_name: "Event"))
    TopicConfigurationDeprecated.add_member(:topic, Shapes::ShapeRef.new(shape: TopicArn, location_name: "Topic"))
    TopicConfigurationDeprecated.struct_class = Types::TopicConfigurationDeprecated

    TopicConfigurationList.member = Shapes::ShapeRef.new(shape: TopicConfiguration)

    Transition.add_member(:date, Shapes::ShapeRef.new(shape: Date, location_name: "Date"))
    Transition.add_member(:days, Shapes::ShapeRef.new(shape: Days, location_name: "Days"))
    Transition.add_member(:storage_class, Shapes::ShapeRef.new(shape: TransitionStorageClass, location_name: "StorageClass"))
    Transition.struct_class = Types::Transition

    TransitionList.member = Shapes::ShapeRef.new(shape: Transition)

    UploadPartCopyOutput.add_member(:copy_source_version_id, Shapes::ShapeRef.new(shape: CopySourceVersionId, location: "header", location_name: "x-amz-copy-source-version-id"))
    UploadPartCopyOutput.add_member(:copy_part_result, Shapes::ShapeRef.new(shape: CopyPartResult, location_name: "CopyPartResult"))
    UploadPartCopyOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    UploadPartCopyOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    UploadPartCopyOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    UploadPartCopyOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    UploadPartCopyOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    UploadPartCopyOutput.struct_class = Types::UploadPartCopyOutput
    UploadPartCopyOutput[:payload] = :copy_part_result
    UploadPartCopyOutput[:payload_member] = UploadPartCopyOutput.member(:copy_part_result)

    UploadPartCopyRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    UploadPartCopyRequest.add_member(:copy_source, Shapes::ShapeRef.new(shape: CopySource, required: true, location: "header", location_name: "x-amz-copy-source"))
    UploadPartCopyRequest.add_member(:copy_source_if_match, Shapes::ShapeRef.new(shape: CopySourceIfMatch, location: "header", location_name: "x-amz-copy-source-if-match"))
    UploadPartCopyRequest.add_member(:copy_source_if_modified_since, Shapes::ShapeRef.new(shape: CopySourceIfModifiedSince, location: "header", location_name: "x-amz-copy-source-if-modified-since"))
    UploadPartCopyRequest.add_member(:copy_source_if_none_match, Shapes::ShapeRef.new(shape: CopySourceIfNoneMatch, location: "header", location_name: "x-amz-copy-source-if-none-match"))
    UploadPartCopyRequest.add_member(:copy_source_if_unmodified_since, Shapes::ShapeRef.new(shape: CopySourceIfUnmodifiedSince, location: "header", location_name: "x-amz-copy-source-if-unmodified-since"))
    UploadPartCopyRequest.add_member(:copy_source_range, Shapes::ShapeRef.new(shape: CopySourceRange, location: "header", location_name: "x-amz-copy-source-range"))
    UploadPartCopyRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    UploadPartCopyRequest.add_member(:part_number, Shapes::ShapeRef.new(shape: PartNumber, required: true, location: "querystring", location_name: "partNumber"))
    UploadPartCopyRequest.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, required: true, location: "querystring", location_name: "uploadId"))
    UploadPartCopyRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    UploadPartCopyRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    UploadPartCopyRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    UploadPartCopyRequest.add_member(:copy_source_sse_customer_algorithm, Shapes::ShapeRef.new(shape: CopySourceSSECustomerAlgorithm, location: "header", location_name: "x-amz-copy-source-server-side-encryption-customer-algorithm"))
    UploadPartCopyRequest.add_member(:copy_source_sse_customer_key, Shapes::ShapeRef.new(shape: CopySourceSSECustomerKey, location: "header", location_name: "x-amz-copy-source-server-side-encryption-customer-key"))
    UploadPartCopyRequest.add_member(:copy_source_sse_customer_key_md5, Shapes::ShapeRef.new(shape: CopySourceSSECustomerKeyMD5, location: "header", location_name: "x-amz-copy-source-server-side-encryption-customer-key-MD5"))
    UploadPartCopyRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    UploadPartCopyRequest.struct_class = Types::UploadPartCopyRequest

    UploadPartOutput.add_member(:server_side_encryption, Shapes::ShapeRef.new(shape: ServerSideEncryption, location: "header", location_name: "x-amz-server-side-encryption"))
    UploadPartOutput.add_member(:etag, Shapes::ShapeRef.new(shape: ETag, location: "header", location_name: "ETag"))
    UploadPartOutput.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    UploadPartOutput.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    UploadPartOutput.add_member(:ssekms_key_id, Shapes::ShapeRef.new(shape: SSEKMSKeyId, location: "header", location_name: "x-amz-server-side-encryption-aws-kms-key-id"))
    UploadPartOutput.add_member(:request_charged, Shapes::ShapeRef.new(shape: RequestCharged, location: "header", location_name: "x-amz-request-charged"))
    UploadPartOutput.struct_class = Types::UploadPartOutput

    UploadPartRequest.add_member(:body, Shapes::ShapeRef.new(shape: Body, location_name: "Body", metadata: {"streaming"=>true}))
    UploadPartRequest.add_member(:bucket, Shapes::ShapeRef.new(shape: BucketName, required: true, location: "uri", location_name: "Bucket"))
    UploadPartRequest.add_member(:content_length, Shapes::ShapeRef.new(shape: ContentLength, location: "header", location_name: "Content-Length"))
    UploadPartRequest.add_member(:content_md5, Shapes::ShapeRef.new(shape: ContentMD5, location: "header", location_name: "Content-MD5"))
    UploadPartRequest.add_member(:key, Shapes::ShapeRef.new(shape: ObjectKey, required: true, location: "uri", location_name: "Key"))
    UploadPartRequest.add_member(:part_number, Shapes::ShapeRef.new(shape: PartNumber, required: true, location: "querystring", location_name: "partNumber"))
    UploadPartRequest.add_member(:upload_id, Shapes::ShapeRef.new(shape: MultipartUploadId, required: true, location: "querystring", location_name: "uploadId"))
    UploadPartRequest.add_member(:sse_customer_algorithm, Shapes::ShapeRef.new(shape: SSECustomerAlgorithm, location: "header", location_name: "x-amz-server-side-encryption-customer-algorithm"))
    UploadPartRequest.add_member(:sse_customer_key, Shapes::ShapeRef.new(shape: SSECustomerKey, location: "header", location_name: "x-amz-server-side-encryption-customer-key"))
    UploadPartRequest.add_member(:sse_customer_key_md5, Shapes::ShapeRef.new(shape: SSECustomerKeyMD5, location: "header", location_name: "x-amz-server-side-encryption-customer-key-MD5"))
    UploadPartRequest.add_member(:request_payer, Shapes::ShapeRef.new(shape: RequestPayer, location: "header", location_name: "x-amz-request-payer"))
    UploadPartRequest.struct_class = Types::UploadPartRequest
    UploadPartRequest[:payload] = :body
    UploadPartRequest[:payload_member] = UploadPartRequest.member(:body)

    UserMetadata.member = Shapes::ShapeRef.new(shape: MetadataEntry, location_name: "MetadataEntry")

    VersioningConfiguration.add_member(:mfa_delete, Shapes::ShapeRef.new(shape: MFADelete, location_name: "MfaDelete"))
    VersioningConfiguration.add_member(:status, Shapes::ShapeRef.new(shape: BucketVersioningStatus, location_name: "Status"))
    VersioningConfiguration.struct_class = Types::VersioningConfiguration

    WebsiteConfiguration.add_member(:error_document, Shapes::ShapeRef.new(shape: ErrorDocument, location_name: "ErrorDocument"))
    WebsiteConfiguration.add_member(:index_document, Shapes::ShapeRef.new(shape: IndexDocument, location_name: "IndexDocument"))
    WebsiteConfiguration.add_member(:redirect_all_requests_to, Shapes::ShapeRef.new(shape: RedirectAllRequestsTo, location_name: "RedirectAllRequestsTo"))
    WebsiteConfiguration.add_member(:routing_rules, Shapes::ShapeRef.new(shape: RoutingRules, location_name: "RoutingRules"))
    WebsiteConfiguration.struct_class = Types::WebsiteConfiguration


    # @api private
    API = Seahorse::Model::Api.new.tap do |api|

      api.version = "2006-03-01"

      api.metadata = {
        "endpointPrefix" => "s3",
        "protocol" => "rest-xml",
        "serviceFullName" => "Amazon Simple Storage Service",
        "timestampFormat" => "rfc822",
      }

      api.add_operation(:abort_multipart_upload, Seahorse::Model::Operation.new.tap do |o|
        o.name = "AbortMultipartUpload"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: AbortMultipartUploadRequest)
        o.output = Shapes::ShapeRef.new(shape: AbortMultipartUploadOutput)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchUpload)
      end)

      api.add_operation(:complete_multipart_upload, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CompleteMultipartUpload"
        o.http_method = "POST"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: CompleteMultipartUploadRequest)
        o.output = Shapes::ShapeRef.new(shape: CompleteMultipartUploadOutput)
      end)

      api.add_operation(:copy_object, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CopyObject"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: CopyObjectRequest)
        o.output = Shapes::ShapeRef.new(shape: CopyObjectOutput)
        o.errors << Shapes::ShapeRef.new(shape: ObjectNotInActiveTierError)
      end)

      api.add_operation(:create_bucket, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CreateBucket"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}"
        o.input = Shapes::ShapeRef.new(shape: CreateBucketRequest)
        o.output = Shapes::ShapeRef.new(shape: CreateBucketOutput)
        o.errors << Shapes::ShapeRef.new(shape: BucketAlreadyExists)
        o.errors << Shapes::ShapeRef.new(shape: BucketAlreadyOwnedByYou)
      end)

      api.add_operation(:create_multipart_upload, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CreateMultipartUpload"
        o.http_method = "POST"
        o.http_request_uri = "/{Bucket}/{Key+}?uploads"
        o.input = Shapes::ShapeRef.new(shape: CreateMultipartUploadRequest)
        o.output = Shapes::ShapeRef.new(shape: CreateMultipartUploadOutput)
      end)

      api.add_operation(:delete_bucket, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucket"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_analytics_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketAnalyticsConfiguration"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?analytics"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketAnalyticsConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_cors, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketCors"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?cors"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketCorsRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_encryption, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketEncryption"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?encryption"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketEncryptionRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_inventory_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketInventoryConfiguration"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?inventory"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketInventoryConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_lifecycle, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketLifecycle"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?lifecycle"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketLifecycleRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_metrics_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketMetricsConfiguration"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?metrics"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketMetricsConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_policy, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketPolicy"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?policy"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketPolicyRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_replication, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketReplication"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?replication"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketReplicationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_tagging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketTagging"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?tagging"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketTaggingRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_bucket_website, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteBucketWebsite"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}?website"
        o.input = Shapes::ShapeRef.new(shape: DeleteBucketWebsiteRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:delete_object, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteObject"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: DeleteObjectRequest)
        o.output = Shapes::ShapeRef.new(shape: DeleteObjectOutput)
      end)

      api.add_operation(:delete_object_tagging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteObjectTagging"
        o.http_method = "DELETE"
        o.http_request_uri = "/{Bucket}/{Key+}?tagging"
        o.input = Shapes::ShapeRef.new(shape: DeleteObjectTaggingRequest)
        o.output = Shapes::ShapeRef.new(shape: DeleteObjectTaggingOutput)
      end)

      api.add_operation(:delete_objects, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteObjects"
        o.http_method = "POST"
        o.http_request_uri = "/{Bucket}?delete"
        o.input = Shapes::ShapeRef.new(shape: DeleteObjectsRequest)
        o.output = Shapes::ShapeRef.new(shape: DeleteObjectsOutput)
      end)

      api.add_operation(:get_bucket_accelerate_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketAccelerateConfiguration"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?accelerate"
        o.input = Shapes::ShapeRef.new(shape: GetBucketAccelerateConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketAccelerateConfigurationOutput)
      end)

      api.add_operation(:get_bucket_acl, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketAcl"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?acl"
        o.input = Shapes::ShapeRef.new(shape: GetBucketAclRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketAclOutput)
      end)

      api.add_operation(:get_bucket_analytics_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketAnalyticsConfiguration"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?analytics"
        o.input = Shapes::ShapeRef.new(shape: GetBucketAnalyticsConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketAnalyticsConfigurationOutput)
      end)

      api.add_operation(:get_bucket_cors, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketCors"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?cors"
        o.input = Shapes::ShapeRef.new(shape: GetBucketCorsRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketCorsOutput)
      end)

      api.add_operation(:get_bucket_encryption, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketEncryption"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?encryption"
        o.input = Shapes::ShapeRef.new(shape: GetBucketEncryptionRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketEncryptionOutput)
      end)

      api.add_operation(:get_bucket_inventory_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketInventoryConfiguration"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?inventory"
        o.input = Shapes::ShapeRef.new(shape: GetBucketInventoryConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketInventoryConfigurationOutput)
      end)

      api.add_operation(:get_bucket_lifecycle, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketLifecycle"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?lifecycle"
        o.deprecated = true
        o.input = Shapes::ShapeRef.new(shape: GetBucketLifecycleRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketLifecycleOutput)
      end)

      api.add_operation(:get_bucket_lifecycle_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketLifecycleConfiguration"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?lifecycle"
        o.input = Shapes::ShapeRef.new(shape: GetBucketLifecycleConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketLifecycleConfigurationOutput)
      end)

      api.add_operation(:get_bucket_location, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketLocation"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?location"
        o.input = Shapes::ShapeRef.new(shape: GetBucketLocationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketLocationOutput)
      end)

      api.add_operation(:get_bucket_logging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketLogging"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?logging"
        o.input = Shapes::ShapeRef.new(shape: GetBucketLoggingRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketLoggingOutput)
      end)

      api.add_operation(:get_bucket_metrics_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketMetricsConfiguration"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?metrics"
        o.input = Shapes::ShapeRef.new(shape: GetBucketMetricsConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketMetricsConfigurationOutput)
      end)

      api.add_operation(:get_bucket_notification, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketNotification"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?notification"
        o.deprecated = true
        o.input = Shapes::ShapeRef.new(shape: GetBucketNotificationConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: NotificationConfigurationDeprecated)
      end)

      api.add_operation(:get_bucket_notification_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketNotificationConfiguration"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?notification"
        o.input = Shapes::ShapeRef.new(shape: GetBucketNotificationConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: NotificationConfiguration)
      end)

      api.add_operation(:get_bucket_policy, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketPolicy"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?policy"
        o.input = Shapes::ShapeRef.new(shape: GetBucketPolicyRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketPolicyOutput)
      end)

      api.add_operation(:get_bucket_replication, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketReplication"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?replication"
        o.input = Shapes::ShapeRef.new(shape: GetBucketReplicationRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketReplicationOutput)
      end)

      api.add_operation(:get_bucket_request_payment, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketRequestPayment"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?requestPayment"
        o.input = Shapes::ShapeRef.new(shape: GetBucketRequestPaymentRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketRequestPaymentOutput)
      end)

      api.add_operation(:get_bucket_tagging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketTagging"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?tagging"
        o.input = Shapes::ShapeRef.new(shape: GetBucketTaggingRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketTaggingOutput)
      end)

      api.add_operation(:get_bucket_versioning, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketVersioning"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?versioning"
        o.input = Shapes::ShapeRef.new(shape: GetBucketVersioningRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketVersioningOutput)
      end)

      api.add_operation(:get_bucket_website, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetBucketWebsite"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?website"
        o.input = Shapes::ShapeRef.new(shape: GetBucketWebsiteRequest)
        o.output = Shapes::ShapeRef.new(shape: GetBucketWebsiteOutput)
      end)

      api.add_operation(:get_object, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetObject"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: GetObjectRequest)
        o.output = Shapes::ShapeRef.new(shape: GetObjectOutput)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchKey)
      end)

      api.add_operation(:get_object_acl, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetObjectAcl"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}/{Key+}?acl"
        o.input = Shapes::ShapeRef.new(shape: GetObjectAclRequest)
        o.output = Shapes::ShapeRef.new(shape: GetObjectAclOutput)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchKey)
      end)

      api.add_operation(:get_object_tagging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetObjectTagging"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}/{Key+}?tagging"
        o.input = Shapes::ShapeRef.new(shape: GetObjectTaggingRequest)
        o.output = Shapes::ShapeRef.new(shape: GetObjectTaggingOutput)
      end)

      api.add_operation(:get_object_torrent, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetObjectTorrent"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}/{Key+}?torrent"
        o.input = Shapes::ShapeRef.new(shape: GetObjectTorrentRequest)
        o.output = Shapes::ShapeRef.new(shape: GetObjectTorrentOutput)
      end)

      api.add_operation(:head_bucket, Seahorse::Model::Operation.new.tap do |o|
        o.name = "HeadBucket"
        o.http_method = "HEAD"
        o.http_request_uri = "/{Bucket}"
        o.input = Shapes::ShapeRef.new(shape: HeadBucketRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NoSuchBucket)
      end)

      api.add_operation(:head_object, Seahorse::Model::Operation.new.tap do |o|
        o.name = "HeadObject"
        o.http_method = "HEAD"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: HeadObjectRequest)
        o.output = Shapes::ShapeRef.new(shape: HeadObjectOutput)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchKey)
      end)

      api.add_operation(:list_bucket_analytics_configurations, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListBucketAnalyticsConfigurations"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?analytics"
        o.input = Shapes::ShapeRef.new(shape: ListBucketAnalyticsConfigurationsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListBucketAnalyticsConfigurationsOutput)
      end)

      api.add_operation(:list_bucket_inventory_configurations, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListBucketInventoryConfigurations"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?inventory"
        o.input = Shapes::ShapeRef.new(shape: ListBucketInventoryConfigurationsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListBucketInventoryConfigurationsOutput)
      end)

      api.add_operation(:list_bucket_metrics_configurations, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListBucketMetricsConfigurations"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?metrics"
        o.input = Shapes::ShapeRef.new(shape: ListBucketMetricsConfigurationsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListBucketMetricsConfigurationsOutput)
      end)

      api.add_operation(:list_buckets, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListBuckets"
        o.http_method = "GET"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.output = Shapes::ShapeRef.new(shape: ListBucketsOutput)
      end)

      api.add_operation(:list_multipart_uploads, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListMultipartUploads"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?uploads"
        o.input = Shapes::ShapeRef.new(shape: ListMultipartUploadsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListMultipartUploadsOutput)
        o[:pager] = Aws::Pager.new(
          more_results: "is_truncated",
          limit_key: "max_uploads",
          tokens: {
            "next_key_marker" => "key_marker",
            "next_upload_id_marker" => "upload_id_marker"
          }
        )
      end)

      api.add_operation(:list_object_versions, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListObjectVersions"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?versions"
        o.input = Shapes::ShapeRef.new(shape: ListObjectVersionsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListObjectVersionsOutput)
        o[:pager] = Aws::Pager.new(
          more_results: "is_truncated",
          limit_key: "max_keys",
          tokens: {
            "next_key_marker" => "key_marker",
            "next_version_id_marker" => "version_id_marker"
          }
        )
      end)

      api.add_operation(:list_objects, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListObjects"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}"
        o.input = Shapes::ShapeRef.new(shape: ListObjectsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListObjectsOutput)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchBucket)
        o[:pager] = Aws::Pager.new(
          more_results: "is_truncated",
          limit_key: "max_keys",
          tokens: {
            "next_marker || contents[-1].key" => "marker"
          }
        )
      end)

      api.add_operation(:list_objects_v2, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListObjectsV2"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}?list-type=2"
        o.input = Shapes::ShapeRef.new(shape: ListObjectsV2Request)
        o.output = Shapes::ShapeRef.new(shape: ListObjectsV2Output)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchBucket)
        o[:pager] = Aws::Pager.new(
          limit_key: "max_keys",
          tokens: {
            "next_continuation_token" => "continuation_token"
          }
        )
      end)

      api.add_operation(:list_parts, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListParts"
        o.http_method = "GET"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: ListPartsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListPartsOutput)
        o[:pager] = Aws::Pager.new(
          more_results: "is_truncated",
          limit_key: "max_parts",
          tokens: {
            "next_part_number_marker" => "part_number_marker"
          }
        )
      end)

      api.add_operation(:put_bucket_accelerate_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketAccelerateConfiguration"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?accelerate"
        o.input = Shapes::ShapeRef.new(shape: PutBucketAccelerateConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_acl, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketAcl"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?acl"
        o.input = Shapes::ShapeRef.new(shape: PutBucketAclRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_analytics_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketAnalyticsConfiguration"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?analytics"
        o.input = Shapes::ShapeRef.new(shape: PutBucketAnalyticsConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_cors, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketCors"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?cors"
        o.input = Shapes::ShapeRef.new(shape: PutBucketCorsRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_encryption, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketEncryption"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?encryption"
        o.input = Shapes::ShapeRef.new(shape: PutBucketEncryptionRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_inventory_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketInventoryConfiguration"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?inventory"
        o.input = Shapes::ShapeRef.new(shape: PutBucketInventoryConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_lifecycle, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketLifecycle"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?lifecycle"
        o.deprecated = true
        o.input = Shapes::ShapeRef.new(shape: PutBucketLifecycleRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_lifecycle_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketLifecycleConfiguration"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?lifecycle"
        o.input = Shapes::ShapeRef.new(shape: PutBucketLifecycleConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_logging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketLogging"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?logging"
        o.input = Shapes::ShapeRef.new(shape: PutBucketLoggingRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_metrics_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketMetricsConfiguration"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?metrics"
        o.input = Shapes::ShapeRef.new(shape: PutBucketMetricsConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_notification, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketNotification"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?notification"
        o.deprecated = true
        o.input = Shapes::ShapeRef.new(shape: PutBucketNotificationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_notification_configuration, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketNotificationConfiguration"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?notification"
        o.input = Shapes::ShapeRef.new(shape: PutBucketNotificationConfigurationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_policy, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketPolicy"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?policy"
        o.input = Shapes::ShapeRef.new(shape: PutBucketPolicyRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_replication, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketReplication"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?replication"
        o.input = Shapes::ShapeRef.new(shape: PutBucketReplicationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_request_payment, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketRequestPayment"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?requestPayment"
        o.input = Shapes::ShapeRef.new(shape: PutBucketRequestPaymentRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_tagging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketTagging"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?tagging"
        o.input = Shapes::ShapeRef.new(shape: PutBucketTaggingRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_versioning, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketVersioning"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?versioning"
        o.input = Shapes::ShapeRef.new(shape: PutBucketVersioningRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_bucket_website, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutBucketWebsite"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}?website"
        o.input = Shapes::ShapeRef.new(shape: PutBucketWebsiteRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
      end)

      api.add_operation(:put_object, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutObject"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: PutObjectRequest)
        o.output = Shapes::ShapeRef.new(shape: PutObjectOutput)
      end)

      api.add_operation(:put_object_acl, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutObjectAcl"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}/{Key+}?acl"
        o.input = Shapes::ShapeRef.new(shape: PutObjectAclRequest)
        o.output = Shapes::ShapeRef.new(shape: PutObjectAclOutput)
        o.errors << Shapes::ShapeRef.new(shape: NoSuchKey)
      end)

      api.add_operation(:put_object_tagging, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutObjectTagging"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}/{Key+}?tagging"
        o.input = Shapes::ShapeRef.new(shape: PutObjectTaggingRequest)
        o.output = Shapes::ShapeRef.new(shape: PutObjectTaggingOutput)
      end)

      api.add_operation(:restore_object, Seahorse::Model::Operation.new.tap do |o|
        o.name = "RestoreObject"
        o.http_method = "POST"
        o.http_request_uri = "/{Bucket}/{Key+}?restore"
        o.input = Shapes::ShapeRef.new(shape: RestoreObjectRequest)
        o.output = Shapes::ShapeRef.new(shape: RestoreObjectOutput)
        o.errors << Shapes::ShapeRef.new(shape: ObjectAlreadyInActiveTierError)
      end)

      api.add_operation(:upload_part, Seahorse::Model::Operation.new.tap do |o|
        o.name = "UploadPart"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: UploadPartRequest)
        o.output = Shapes::ShapeRef.new(shape: UploadPartOutput)
      end)

      api.add_operation(:upload_part_copy, Seahorse::Model::Operation.new.tap do |o|
        o.name = "UploadPartCopy"
        o.http_method = "PUT"
        o.http_request_uri = "/{Bucket}/{Key+}"
        o.input = Shapes::ShapeRef.new(shape: UploadPartCopyRequest)
        o.output = Shapes::ShapeRef.new(shape: UploadPartCopyOutput)
      end)
    end

  end
end
