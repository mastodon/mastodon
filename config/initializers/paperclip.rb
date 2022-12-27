# frozen_string_literal: true

Paperclip::DataUriAdapter.register
Paperclip::ResponseWithLimitAdapter.register

Paperclip.interpolates :filename do |attachment, style|
  if style == :original
    attachment.original_filename
  else
    [basename(attachment, style), extension(attachment, style)].delete_if(&:blank?).join('.')
  end
end

Paperclip.interpolates :prefix_path do |attachment, style|
  if attachment.storage_schema_version >= 1 && attachment.instance.respond_to?(:local?) && !attachment.instance.local?
    'cache' + File::SEPARATOR
  else
    ''
  end
end

Paperclip.interpolates :prefix_url do |attachment, style|
  if attachment.storage_schema_version >= 1 && attachment.instance.respond_to?(:local?) && !attachment.instance.local?
    'cache/'
  else
    ''
  end
end

Paperclip::Attachment.default_options.merge!(
  use_timestamp: false,
  path: ':prefix_url:class/:attachment/:id_partition/:style/:filename',
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
      http_open_timeout: ENV.fetch('S3_OPEN_TIMEOUT'){ '5' }.to_i,
      http_read_timeout: ENV.fetch('S3_READ_TIMEOUT'){ '5' }.to_i,
      http_idle_timeout: 5,
      retry_limit: 0,
    }
  )
  
  if ENV['S3_PERMISSION'] == ''
    Paperclip::Attachment.default_options.merge!(
      s3_permissions: ->(*) { nil }
    )
  end

  if ENV.has_key?('S3_ENDPOINT')
    Paperclip::Attachment.default_options[:s3_options].merge!(
      endpoint: ENV['S3_ENDPOINT'],
      force_path_style: ENV['S3_OVERRIDE_PATH_STYLE'] != 'true',
    )

    Paperclip::Attachment.default_options[:url] = ':s3_path_url'
  end

  if ENV.has_key?('S3_ALIAS_HOST') || ENV.has_key?('S3_CLOUDFRONT_HOST')
    Paperclip::Attachment.default_options.merge!(
      url: ':s3_alias_url',
      s3_host_alias: ENV['S3_ALIAS_HOST'] || ENV['S3_CLOUDFRONT_HOST']
    )
  end

  # Some S3-compatible providers might not actually be compatible with some APIs
  # used by kt-paperclip, see https://github.com/mastodon/mastodon/issues/16822
  if ENV['S3_FORCE_SINGLE_REQUEST'] == 'true'
    module Paperclip
      module Storage
        module S3Extensions
          def copy_to_local_file(style, local_dest_path)
            log("copying #{path(style)} to local file #{local_dest_path}")
            s3_object(style).download_file(local_dest_path, { mode: 'single_request' })
          rescue Aws::Errors::ServiceError => e
            warn("#{e} - cannot copy #{path(style)} to local file #{local_dest_path}")
            false
          end
        end
      end
    end

    Paperclip::Storage::S3.prepend(Paperclip::Storage::S3Extensions)
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
    
    fog_file: { 'Cache-Control' => 'public, max-age=315576000, immutable' },

    fog_directory: ENV['SWIFT_CONTAINER'],
    fog_host: ENV['SWIFT_OBJECT_URL'],
    fog_public: true
  )
else
  Paperclip::Attachment.default_options.merge!(
    storage: :filesystem,
    path: File.join(ENV.fetch('PAPERCLIP_ROOT_PATH', File.join(':rails_root', 'public', 'system')), ':prefix_path:class', ':attachment', ':id_partition', ':style', ':filename'),
    url: ENV.fetch('PAPERCLIP_ROOT_URL', '/system') + '/:prefix_url:class/:attachment/:id_partition/:style/:filename',
  )
end

Rails.application.reloader.to_prepare do
  Paperclip.options[:content_type_mappings] = { csv: Import::FILE_TYPES }
end

# In some places in the code, we rescue this exception, but we don't always
# load the S3 library, so it may be an undefined constant:

unless defined?(Seahorse)
  module Seahorse
    module Client
      class NetworkingError < StandardError; end
    end
  end
end
