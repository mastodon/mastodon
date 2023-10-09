# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    vary_by 'Accept, Accept-Language, Cookie'

    before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_pack
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

    redirect_path = PermalinkRedirector.new(request.path).redirect_path
    return if redirect_path.blank?

    expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.day) unless user_signed_in?
    redirect_to(redirect_path)
  end

  def set_pack
    use_pack 'home'
  end
end
