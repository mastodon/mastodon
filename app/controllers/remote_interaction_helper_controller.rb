# frozen_string_literal: true

class RemoteInteractionHelperController < ApplicationController
  vary_by ''

  skip_before_action :require_functional!
  skip_around_action :set_locale
  skip_before_action :update_user_sign_in

  content_security_policy do |p|
    # We inherit the normal `script-src`

    # Set every directive that does not have a fallback
    p.default_src :none
    p.form_action :none
    p.base_uri :none

    # Disable every directive with a fallback to cut on response size
    p.base_uri false
    p.font_src false
    p.img_src false
    p.style_src false
    p.media_src false
    p.frame_src false
    p.manifest_src false
    p.connect_src false
    p.child_src false
    p.worker_src false

    # Widen the directives that we do need
    p.frame_ancestors :self
    p.connect_src :https
  end

  def index
    expires_in(5.minutes, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day)

    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['Referrer-Policy'] = 'no-referrer'

    render layout: 'helper_frame'
  end
end
