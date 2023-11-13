# frozen_string_literal: true

module Api::ContentSecurityPolicy
  extend ActiveSupport::Concern

  FALLBACK_DIRECTIVES = %i(
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
  ).freeze

  NON_FALLBACK_DIRECTIVES = %i(
    default_src
    frame_ancestors
    form_action
  ).freeze

  included do
    content_security_policy do |policy|
      NON_FALLBACK_DIRECTIVES.each do |directive|
        policy.send directive, :none
      end

      FALLBACK_DIRECTIVES.each do |directive|
        policy.send directive, false
      end
    end
  end
end
