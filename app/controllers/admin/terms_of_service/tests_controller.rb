# frozen_string_literal: true

class Admin::TermsOfService::TestsController < Admin::BaseController
  before_action :set_terms_of_service

  def create
    authorize @terms_of_service, :distribute?
    UserMailer.terms_of_service_changed(current_user, @terms_of_service).deliver_later!
    redirect_to admin_terms_of_service_preview_path(@terms_of_service)
  end

  private

  def set_terms_of_service
    @terms_of_service = TermsOfService.find(params[:terms_of_service_id])
  end
end
