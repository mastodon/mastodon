# frozen_string_literal: true

Paperclip.options[:read_timeout] = 60

Paperclip.interpolates :filename do |attachment, style|
  [basename(attachment, style), extension(attachment, style)].delete_if(&:blank?).join('.')
end

Paperclip::Attachment.default_options.merge!(
  use_timestamp: false,
  path: ':class/:attachment/:id_partition/:style/:filename',
  storage: :fog
)

if ENV['S3_ENABLED'] == 'true'
  require 'aws-sdk-s3'

  s3_region   = ENV.fetch('S3_REGION')   { 'us-east-1' }
  s3_protocol = ENV.fetch('S3_PROTOCOL') { 'https' }
  s3_hostname = ENV.fetch('S3_HOSTNAME') { "s3-#{s3_region}.amazonaws.com" }

  Paperclip::Attachment.default_options.merge!(
    storage: :s3,
    s3_protocol: s3_protocol,
    s3_host_name: s3_hostname,
    s3_headers: {
      'X-Amz-Multipart-Threshold' => ENV.fetch('S3_MULTIPART_THRESHOLD') { 15.megabytes }.to_i,
      'Cache-Control' => 'public, max-age=315576000, immutable',
    },
    s3_permissions: ENV.fetch('S3_PERMISSION') { 'public-read' },
    s3_region: s3_region,
    s3_credentials: {
      bucket: ENV['S3_BUCKET'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    },
    s3_options: {
      signature_version: ENV.fetch('S3_SIGNATURE_VERSION') { 'v4' },
      http_open_timeout: 5,
      http_read_timeout: 5,
      http_idle_timeout: 5,
    }
  )

  if ENV.has_key?('S3_ENDPOINT')
    Paperclip::Attachment.default_options[:s3_options].merge!(
      endpoint: ENV['S3_ENDPOINT'],
      force_path_style: true
    )
    Paperclip::Attachment.default_options[:url] = ':s3_path_url'
  end

  if ENV.has_key?('S3_ALIAS_HOST') || ENV.has_key?('S3_CLOUDFRONT_HOST')
    Paperclip::Attachment.default_options.merge!(
      url: ':s3_alias_url',
      s3_host_alias: ENV['S3_ALIAS_HOST'] || ENV['S3_CLOUDFRONT_HOST']
    )
  end
elsif ENV['SWIFT_ENABLED'] == 'true'
  require 'fog/openstack'

  Paperclip::Attachment.default_options.merge!(
    fog_credentials: {
      provider: 'OpenStack',
      openstack_username: ENV['SWIFT_USERNAME'],
      openstack_project_id: ENV['SWIFT_PROJECT_ID'],
      openstack_project_name: ENV['SWIFT_TENANT'],
      openstack_tenant: ENV['SWIFT_TENANT'], # Some OpenStack-v2 ignores project_name but needs tenant
      openstack_api_key: ENV['SWIFT_PASSWORD'],
      openstack_auth_url: ENV['SWIFT_AUTH_URL'],
      openstack_domain_name: ENV.fetch('SWIFT_DOMAIN_NAME') { 'default' },
      openstack_region: ENV['SWIFT_REGION'],
      openstack_cache_ttl: ENV.fetch('SWIFT_CACHE_TTL') { 60 },
    },
    fog_directory: ENV['SWIFT_CONTAINER'],
    fog_host: ENV['SWIFT_OBJECT_URL'],
    fog_public: true
  )
else
  Paperclip::Attachment.default_options.merge!(
    storage: :filesystem,
    use_timestamp: true,
    path: (ENV['PAPERCLIP_ROOT_PATH'] || ':rails_root/public/system') + '/:class/:attachment/:id_partition/:style/:filename',
    url: (ENV['PAPERCLIP_ROOT_URL'] || '/system') + '/:class/:attachment/:id_partition/:style/:filename',
  )
end
