# frozen_string_literal: true

class Api::Web::EmbedsController < Api::Web::BaseController
  before_action :require_user!

  def create
    status = StatusFinder.new(params[:url]).status

    return not_found if status.hidden?

    render json: status, serializer: OEmbedSerializer, width: 400
  rescue ActiveRecord::RecordNotFound
    oembed = FetchOEmbedService.new.call(params[:url])

    return not_found if oembed.nil?

    begin
      oembed[:html] = Formatter.instance.sanitize(oembed[:html], Sanitize::Config::MASTODON_OEMBED)
    rescue ArgumentError
      return not_found
    end

    render json: oembed
  end
end
