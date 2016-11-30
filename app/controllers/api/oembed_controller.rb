# frozen_string_literal: true

class Api::OembedController < ApiController
  respond_to :json

  def show
    @stream_entry = stream_entry_from_url(params[:url])
    @width        = [300, params[:maxwidth].to_i].min
    @height       = [200, params[:maxheight].to_i].min
  end

  private

  def stream_entry_from_url(url)
    params = Rails.application.routes.recognize_path(url)

    raise ActiveRecord::NotFound unless params[:controller] == 'stream_entries' && params[:action] == 'show'

    StreamEntry.find(params[:id])
  end
end
