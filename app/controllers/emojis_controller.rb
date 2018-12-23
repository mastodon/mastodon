# frozen_string_literal: true

class EmojisController < ApplicationController
  before_action :set_emoji

  def show
    respond_to do |format|
      format.json do
        render json: @emoji,
               serializer: ActivityPub::EmojiSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def set_emoji
    @emoji = CustomEmoji.local.find(params[:id])
  end
end
