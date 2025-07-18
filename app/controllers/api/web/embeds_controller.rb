# frozen_string_literal: true

class Api::Web::EmbedsController < Api::Web::BaseController
  include Authorization

  before_action :set_status
  before_action :verify_embed_allowed
  with_options unless: -> { @status.local? } do
    before_action :require_signed_in
    before_action :set_oembed
    before_action :populate_oembed_html
  end

  def show
    if @status.local?
      render json: @status, serializer: OEmbedSerializer
    else
      render json: @oembed
    end
  end

  private

  def verify_embed_allowed
    not_found if @status.hidden?
  end

  def require_signed_in
    not_found unless user_signed_in?
  end

  def set_oembed
    url = ActivityPub::TagManager.instance.url_for(@status)
    @oembed = FetchOEmbedService.new.call(url)
    not_found if @oembed.nil?
  end

  def populate_oembed_html
    begin
      @oembed[:html] = Sanitize.fragment(@oembed[:html], Sanitize::Config::MASTODON_OEMBED)
    rescue ArgumentError
      not_found
    end
  end

  def set_status
    @status = Status.find(params[:id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
