# frozen_string_literal: true

class Api::OEmbedController < ApiController
  respond_to :json

  def show
    @stream_entry = stream_entry_from_url(params[:url])
    @width        = params[:maxwidth].present?  ? params[:maxwidth].to_i  : 400
    @height       = params[:maxheight].present? ? params[:maxheight].to_i : nil
  end

  private

  def stream_entry_from_url(url)
    params = Rails.application.routes.recognize_path(url)

    raise ActiveRecord::RecordNotFound unless recognized_stream_entry_url?(params)

    stream_entry(params)
  end

  def recognized_stream_entry_url?(params)
    %w(stream_entries statuses).include?(params[:controller]) && params[:action] == 'show'
  end

  def stream_entry(params)
    if params[:controller] == 'stream_entries'
      StreamEntry.find(params[:id])
    else
      Status.find(params[:id]).stream_entry
    end
  end
end
