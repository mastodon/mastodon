# frozen_string_literal: true

class Admin::TermsOfService::PreviewsController < Admin::BaseController
  before_action :set_terms_of_service

  def show
    authorize @terms_of_service, :distribute?
    @user_count = @terms_of_service.scope_for_notification.count
  end

  private

  def set_terms_of_service
    @terms_of_service = TermsOfService.find(params[:terms_of_service_id])
  end
end
