if ENV['S3_ENABLED'] == 'true'
  Paperclip::Attachment.default_options[:storage]     = :s3
  Paperclip::Attachment.default_options[:s3_protocol] = 'https'
  Paperclip::Attachment.default_options[:url]         = ':s3_domain_url'
  Paperclip::Attachment.default_options[:path]        = '/:class/:attachment/:id_partition/:style/:filename'

  Paperclip::Attachment.default_options[:s3_credentials] = {
    bucket: ENV.fetch('S3_BUCKET'),
    access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
    s3_region: ENV.fetch('S3_REGION')
  }
end
