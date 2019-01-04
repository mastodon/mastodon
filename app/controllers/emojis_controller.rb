# frozen_string_literal: true

class EmojisController < ApplicationController
  before_action :set_emoji
  before_action :set_cache_headers

  def show
    respond_to do |format|
      format.json do
        skip_session!

        render_cached_json(['activitypub', 'emoji', @emoji.cache_key], content_type: 'application/activity+json') do
          ActiveModelSerializers::SerializableResource.new(@emoji, serializer: ActivityPub::EmojiSerializer, adapter: ActivityPub::Adapter)
        end
      end
    end
  end

  private

  def set_emoji
    @emoji = CustomEmoji.local.find(params[:id])
  end
end
