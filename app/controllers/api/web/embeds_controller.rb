# frozen_string_literal: true

class Api::Web::EmbedsController < Api::Web::BaseController
  include Authorization

  before_action :set_status

  def show
    return not_found if @status.hidden?

    if @status.local?
      render json: @status, serializer: OEmbedSerializer
    else
      return not_found unless user_signed_in?

      url = ActivityPub::TagManager.instance.url_for(@status)
      oembed = FetchOEmbedService.new.call(url)
      return not_found if oembed.nil?

      begin
        oembed[:html] = Sanitize.fragment(oembed[:html], Sanitize::Config::MASTODON_OEMBED)
      rescue ArgumentError
        return not_found
      end

      render json: oembed
    end
  end

  def set_status
    @status = Status.find(params[:id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
