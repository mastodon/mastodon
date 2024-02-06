# frozen_string_literal: true

class EmojisController < ApplicationController
  before_action :set_emoji

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  def show
    expires_in 3.minutes, public: true
    render_with_cache json: @emoji, content_type: 'application/activity+json', serializer: ActivityPub::EmojiSerializer, adapter: ActivityPub::Adapter
  end

  private

  def set_emoji
    @emoji = CustomEmoji.local.find(params[:id])
  end
end
