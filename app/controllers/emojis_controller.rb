# frozen_string_literal: true

class EmojisController < ApplicationController
  before_action :set_emoji

  def show
    respond_to do |format|
      format.json do
        render json: @emoji, serializer: ActivityPub::CustomEmojiIconSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
      end

      format.atom do
        render xml: OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.emoji_icon(@emoji, true))
      end
    end
  end

  private

  def set_emoji
    @emoji = CustomEmojiIcon.local.find(params.require(:id))
  end
end
