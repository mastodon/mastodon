# frozen_string_literal: true

class Api::V1::Instances::TermsOfServicesController < Api::V1::Instances::BaseController
  before_action :set_terms_of_service

  def show
    cache_even_if_authenticated!
    render json: @terms_of_service, serializer: REST::TermsOfServiceSerializer
  end

  private

  def set_terms_of_service
    @terms_of_service = begin
      if params[:date].present?
        TermsOfService.published.find_by!(effective_date: params[:date])
      else
        TermsOfService.live.first || TermsOfService.published.first! # For the case when none of the published terms have become effective yet
      end
    end
  end
end
