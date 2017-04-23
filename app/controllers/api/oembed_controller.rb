# frozen_string_literal: true

class Api::OEmbedController < ApiController
  respond_to :json

  def show
    @stream_entry = stream_entry_from_url(params[:url])
    @width        = params[:maxwidth].present?  ? params[:maxwidth].to_i  : 400
    @height       = params[:maxheight].present? ? params[:maxheight].to_i : 600
  end

  private

  def stream_entry_from_url(url)
    params = Rails.application.routes.recognize_path(url)

    raise ActiveRecord::RecordNotFound unless %w(stream_entries statuses).include?(params[:controller]) && params[:action] == 'show'

    return StreamEntry.find(params[:id]) if params[:controller] == 'stream_entries'
    Status.find(params[:id]).stream_entry
  end
end
