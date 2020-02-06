# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

if Rails.env.production?
  assets_host = Rails.configuration.action_controller.asset_host || "https://#{ENV['WEB_DOMAIN'] || ENV['LOCAL_DOMAIN']}"
  data_hosts = [assets_host]

  if ENV['S3_ENABLED'] == 'true'
    attachments_host = "https://#{ENV['S3_ALIAS_HOST'] || ENV['S3_CLOUDFRONT_HOST'] || ENV['S3_HOSTNAME'] || "s3-#{ENV['S3_REGION'] || 'us-east-1'}.amazonaws.com"}"
    attachments_host = "https://#{Addressable::URI.parse(attachments_host).host}"
  elsif ENV['SWIFT_ENABLED'] == 'true'
    attachments_host = ENV['SWIFT_OBJECT_URL']
    attachments_host = "https://#{Addressable::URI.parse(attachments_host).host}"
  else
    attachments_host = nil
  end

  data_hosts << attachments_host unless attachments_host.nil?

  if ENV['PAPERCLIP_ROOT_URL']
    url = Addressable::URI.parse(assets_host) + ENV['PAPERCLIP_ROOT_URL']
    data_hosts << "https://#{url.host}"
  end

  data_hosts.concat(ENV['EXTRA_DATA_HOSTS'].split('|')) if ENV['EXTRA_DATA_HOSTS']

  data_hosts.uniq!

  Rails.application.config.content_security_policy do |p|
    p.base_uri        :none
    p.default_src     :none
    p.frame_ancestors :none
    p.script_src      :self, assets_host
    p.font_src        :self, assets_host
    p.img_src         :self, :data, :blob, *data_hosts
    p.style_src       :self, :unsafe_inline, assets_host
    p.media_src       :self, :data, *data_hosts
    p.frame_src       :self, :https
    p.worker_src      :self, :blob, assets_host
    p.connect_src     :self, :blob, :data, Rails.configuration.x.streaming_api_base_url, *data_hosts
    p.manifest_src    :self, assets_host
  end
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
