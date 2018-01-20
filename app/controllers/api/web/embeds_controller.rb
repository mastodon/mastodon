# frozen_string_literal: true

class Api::Web::EmbedsController < Api::BaseController
  respond_to :json

  before_action :require_user!

  def create
    if TagManager.instance.local_url? params[:url]
      status = TagManager.instance.url_to_resource!(params[:url], Status)
      render json: status, serializer: OEmbedSerializer, width: 400
    else
      oembed = OEmbed::Providers.get(params[:url])
      render json: Oj.dump(oembed.fields)
    end
  rescue OEmbed::NotFound
    render json: {}, status: :not_found
  end
end
