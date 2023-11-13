# frozen_string_literal: true

module Api::ContentSecurityPolicy
  extend ActiveSupport::Concern

  included do
    content_security_policy do |policy|
      %i(
        default_src
        frame_ancestors
        form_action
      ).each { |directive| policy.send directive, :none }

      %i(
        base_uri
        font_src
        img_src
        style_src
        media_src
        frame_src
        manifest_src
        connect_src
        script_src
        child_src
        worker_src
      ).each { |directive| policy.send directive, false }
    end
  end
end
