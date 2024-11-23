# frozen_string_literal: true

class Api::V1::Instances::TermsOfServicesController < Api::V1::Instances::BaseController
  before_action :set_terms_of_service

  def show
    cache_even_if_authenticated!
    render json: @terms_of_service, serializer: REST::PrivacyPolicySerializer
  end

  private

  def set_terms_of_service
    @terms_of_service = TermsOfService.live.first!
  end
end
