# frozen_string_literal: true

Paperclip.options[:read_timeout] = 60

Paperclip.interpolates :filename do |attachment, style|
  return attachment.original_filename if style == :original
  [basename(attachment, style), extension(attachment, style)].delete_if(&:blank?).join('.')
end

Paperclip::Attachment.default_options.merge!(
  use_timestamp: false,
  path: ':class/:attachment/:id_partition/:style/:filename',
  storage: :fog
)

if ENV['S3_ENABLED'] == 'true'
  require 'fog/aws'

  s3_protocol           = ENV.fetch('S3_PROTOCOL') { 'https' }
  s3_hostname           = ENV.fetch('S3_HOSTNAME') { "s3-#{ENV['S3_REGION']}.amazonaws.com" }
  aws_signature_version = ENV['S3_SIGNATURE_VERSION'] == 's3' ? 2 : ENV['S3_SIGNATURE_VERSION'].to_i
  aws_signature_version = 4 if aws_signature_version.zero?

  Paperclip::Attachment.default_options.merge!(
    fog_credentials: {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      aws_signature_version: aws_signature_version,
      region: ENV.fetch('S3_REGION') { 'us-east-1' },
      scheme: s3_protocol,
      host: s3_hostname
    },
    fog_directory: ENV['S3_BUCKET'],
    fog_options: {
      acl: ENV.fetch('S3_PERMISSION') { 'public-read' },
      cache_control: 'max-age=315576000',
    }
  )

  if ENV.has_key?('S3_ENDPOINT')
    Paperclip::Attachment.default_options[:fog_credentials].merge!(
      endpoint: ENV['S3_ENDPOINT'],
      path_style: true
    )
    Paperclip::Attachment.default_options[:fog_host] = "#{s3_protocol}://#{s3_hostname}/#{ENV['S3_BUCKET']}"
  end

  if ENV.has_key?('S3_CLOUDFRONT_HOST')
    Paperclip::Attachment.default_options[:fog_host] = "#{s3_protocol}://#{ENV['S3_CLOUDFRONT_HOST']}"
  end
elsif ENV['SWIFT_ENABLED'] == 'true'
  require 'fog/openstack'

  Paperclip::Attachment.default_options.merge!(
    fog_credentials: {
      provider: 'OpenStack',
      openstack_username: ENV['SWIFT_USERNAME'],
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
  require 'fog/local'

  Paperclip::Attachment.default_options.merge!(
    fog_credentials: {
      provider: 'Local',
      local_root: ENV.fetch('PAPERCLIP_ROOT_PATH') { Rails.root.join('public', 'system') },
    },
    fog_directory: '',
    fog_host: ENV.fetch('PAPERCLIP_ROOT_URL') { '/system' }
  )
end
