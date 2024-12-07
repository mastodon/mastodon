# frozen_string_literal: true

class Admin::TermsOfService::DraftsController < Admin::BaseController
  before_action :set_terms_of_service

  def show
    authorize :terms_of_service, :create?
  end

  def update
    authorize @terms_of_service, :update?

    @terms_of_service.published_at = Time.now.utc if params[:action_type] == 'publish'

    if @terms_of_service.update(resource_params)
      log_action(:publish, @terms_of_service) if @terms_of_service.published?
      redirect_to @terms_of_service.published? ? admin_terms_of_service_index_path : admin_terms_of_service_draft_path
    else
      render :show
    end
  end

  private

  def set_terms_of_service
    @terms_of_service = TermsOfService.draft.first || TermsOfService.new(text: current_terms_of_service&.text)
  end

  def current_terms_of_service
    TermsOfService.live.first
  end

  def resource_params
    params.require(:terms_of_service).permit(:text, :changelog)
  end
end
