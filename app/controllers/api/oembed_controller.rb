# frozen_string_literal: true

class Api::OEmbedController < ApiController
  respond_to :json

  def show
    @stream_entry = find_stream_entry.stream_entry
    @width = maxwidth_or_default
    @height = maxheight_or_default
  end

  private

  def find_stream_entry
    StreamEntryFinder.new(params[:url])
  end

  def maxwidth_or_default
    (params[:maxwidth].presence || 400).to_i
  end

  def maxheight_or_default
    params[:maxheight].present? ? params[:maxheight].to_i : nil
  end
end
