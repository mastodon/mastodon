# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_app_body_class
    before_action :set_referrer_policy_header
  end

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def set_referrer_policy_header
    response.headers['Referrer-Policy'] = 'origin'
  end

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in?

    redirect_path = PermalinkRedirector.new(request.path).redirect_path

    redirect_to(redirect_path) if redirect_path.present?
  end
end
