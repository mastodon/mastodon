# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

if Rails.env.production?
  assets_host = Rails.configuration.action_controller.asset_host || "https://#{ENV['WEB_DOMAIN'] || ENV['LOCAL_DOMAIN']}"

  Rails.application.config.content_security_policy do |p|
    p.base_uri        :none
    p.default_src     :none
    p.frame_ancestors :none
    p.script_src      :self, assets_host
    p.font_src        :self, assets_host
    p.img_src         :self, :https, :data, :blob
    p.style_src       :self, :unsafe_inline, assets_host
    p.media_src       :self, :data, assets_host
    p.frame_src       :self, :https
    p.connect_src     :self, assets_host, Rails.configuration.x.streaming_api_base_url
  end
end


# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
