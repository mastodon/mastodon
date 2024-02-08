# frozen_string_literal: true

module Api::ContentSecurityPolicy
  extend ActiveSupport::Concern

  included do
    content_security_policy do |policy|
      # Set every directive that does not have a fallback
      policy.default_src :none
      policy.frame_ancestors :none
      policy.form_action :none

      # Disable every directive with a fallback to cut on response size
      policy.base_uri false
      policy.font_src false
      policy.img_src false
      policy.style_src false
      policy.media_src false
      policy.frame_src false
      policy.manifest_src false
      policy.connect_src false
      policy.script_src false
      policy.child_src false
      policy.worker_src false
    end
  end
end
