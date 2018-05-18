# frozen_string_literal: true

class Api::Web::EmbedsController < Api::Web::BaseController
  respond_to :json

  before_action :require_user!

  def create
    status = StatusFinder.new(params[:url]).status
    render json: status, serializer: OEmbedSerializer, width: 400
  rescue ActiveRecord::RecordNotFound
    oembed = FetchOEmbedService.new.call(params[:url])

    if oembed
      render json: oembed
    else
      render json: {}, status: :not_found
    end
  end
end
