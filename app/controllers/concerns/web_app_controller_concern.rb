# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_pack
    before_action :set_app_body_class

    vary_by 'Accept, Accept-Language, Cookie'
  end

  def skip_csrf_meta_tags?
    !(ENV['ONE_CLICK_SSO_LOGIN'] == 'true' && ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1) && current_user.nil?
  end

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in? # NOTE: Different from upstream because we allow moved users to log in

    redirect_path = PermalinkRedirector.new(request.path).redirect_path

    redirect_to(redirect_path) if redirect_path.present?
  end

  def set_pack
    use_pack 'home'
  end
end
