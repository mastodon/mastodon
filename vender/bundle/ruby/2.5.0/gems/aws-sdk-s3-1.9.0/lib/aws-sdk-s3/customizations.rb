# utility classes
require 'aws-sdk-s3/bucket_region_cache'
require 'aws-sdk-s3/encryption'
require 'aws-sdk-s3/file_part'
require 'aws-sdk-s3/file_uploader'
require 'aws-sdk-s3/file_downloader'
require 'aws-sdk-s3/legacy_signer'
require 'aws-sdk-s3/multipart_file_uploader'
require 'aws-sdk-s3/multipart_upload_error'
require 'aws-sdk-s3/object_copier'
require 'aws-sdk-s3/object_multipart_copier'
require 'aws-sdk-s3/presigned_post'
require 'aws-sdk-s3/presigner'

# customizations to generated classes
require 'aws-sdk-s3/customizations/bucket'
require 'aws-sdk-s3/customizations/object'
require 'aws-sdk-s3/customizations/object_summary'
require 'aws-sdk-s3/customizations/multipart_upload'
require 'aws-sdk-s3/customizations/types/list_object_versions_output'

[
  Aws::S3::Object::Collection,
  Aws::S3::ObjectSummary::Collection,
  Aws::S3::ObjectVersion::Collection,
].each do |klass|
  klass.send(:alias_method, :delete, :batch_delete!)
  klass.send(:extend, Aws::Deprecations)
  klass.send(:deprecated, :delete, use: :batch_delete!)
end
