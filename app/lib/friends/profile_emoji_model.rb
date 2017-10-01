# frozen_string_literal: true

module Friends
  module ProfileEmojiModel
    extend ActiveSupport::Concern

    IMAGE_MIME_TYPES = AccountAvatar::IMAGE_MIME_TYPES

    def profile_emoji
      avatar
    end

    def profile_emoji_original_url
      avatar_original_url
    end

    def profile_emoji_static_url
      avatar_static_url
    end
  end
end
