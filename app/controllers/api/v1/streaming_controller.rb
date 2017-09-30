# frozen_string_literal: true

class Api::V1::StreamingController < Api::BaseController
  respond_to :json

  def index
    if Rails.configuration.x.streaming_api_base_url != request.host
      uri = URI.parse(request.url)
      uri.host = URI.parse(Rails.configuration.x.streaming_api_base_url).host
      redirect_to uri.to_s, status: 301
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
