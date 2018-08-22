# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |p|
  p.frame_ancestors :none
  p.object_src  :none
  p.script_src  :self
  p.base_uri :none
#  p.default_src :self, :https
#  p.font_src    :self, :https, :data
#  p.img_src     :self, :https, :data
#  p.style_src   :self, :https, :unsafe_inline
#
#  # Specify URI for violation reports
#  # p.report_uri "/csp-violation-report-endpoint"
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
