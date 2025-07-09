# frozen_string_literal: true

class Admin::TermsOfService::DistributionsController < Admin::BaseController
  before_action :set_terms_of_service

  def create
    authorize @terms_of_service, :distribute?
    @terms_of_service.touch(:notification_sent_at)
    Admin::DistributeTermsOfServiceNotificationWorker.perform_async(@terms_of_service.id)
    redirect_to admin_terms_of_service_index_path
  end

  private

  def set_terms_of_service
    @terms_of_service = TermsOfService.find(params[:terms_of_service_id])
  end
end
