# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :redirect_unauthenticated_to_permalinks!
    before_action :set_app_body_class

    vary_by 'Accept, Accept-Language, Cookie'
  end

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in? && current_account.moved_to_account_id.nil?

    redirect_path = PermalinkRedirector.new(request.path).redirect_path

    redirect_to(redirect_path) if redirect_path.present?
  end
end
