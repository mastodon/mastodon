# frozen_string_literal: true

module Friends
  module StatusProfileEmoji
    extend ActiveSupport::Concern

    include Friends::ProfileEmojiExtension

    def profile_emojis
      get_profile_emojis [spoiler_text, text].join(' '), "profile_emojis:status:#{self.id}"
    end
  end
end
