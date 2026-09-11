# frozen_string_literal: true

class Api::V1::Instances::TermsOfServiceController < Api::V1::Instances::BaseController
  before_action :cache_even_if_authenticated!

  def index
    @terms_of_service = TermsOfService.current || raise(ActiveRecord::RecordNotFound)
    render json: @terms_of_service, serializer: REST::TermsOfServiceSerializer
  end

  def show
    @terms_of_service = TermsOfService.published.find_by!(effective_date: params[:date])
    render json: @terms_of_service, serializer: REST::TermsOfServiceSerializer
  end
end
