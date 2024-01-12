# frozen_string_literal: true

class Api::V1::StreamingController < Api::BaseController
  def index
    if same_host?
      not_found
    else
      redirect_to streaming_api_url, status: 301, allow_other_host: true
    end
  end

  private

  def same_host?
    base_url = Addressable::URI.parse(Rails.configuration.x.streaming_api_base_url)
    request.host == base_url.host && request.port == (base_url.port || 80)
  end

  def streaming_api_url
    Addressable::URI.parse(request.url).tap do |uri|
      base_url = Addressable::URI.parse(Rails.configuration.x.streaming_api_base_url)
      uri.host = base_url.host
      uri.port = base_url.port
    end.to_s
  end
end
