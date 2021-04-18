# frozen_string_literal: true

class Api::V1::StreamingController < Api::BaseController
  def index
    if Rails.configuration.x.streaming_api_base_url != request.host
      redirect_to streaming_api_url, status: 301
    else
      not_found
    end
  end

  private

  def streaming_api_url
    Addressable::URI.parse(request.url).tap do |uri|
      uri.host = Addressable::URI.parse(Rails.configuration.x.streaming_api_base_url).host
    end.to_s
  end
end
