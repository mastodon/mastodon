# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    vary_by 'Accept, Accept-Language, Cookie'

    before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_app_body_class
  end

  def skip_csrf_meta_tags?
    !(ENV['ONE_CLICK_SSO_LOGIN'] == 'true' && ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1) && current_user.nil?
  end

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in? # NOTE: Different from upstream because we allow moved users to log in

    permalink_redirector = PermalinkRedirector.new(request.path)
    return if permalink_redirector.redirect_path.blank?

    expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?

    respond_to do |format|
      format.html do
        redirect_to(permalink_redirector.redirect_confirmation_path, allow_other_host: false)
      end

      format.json do
        redirect_to(permalink_redirector.redirect_uri, allow_other_host: true)
      end
    end
  end
end
