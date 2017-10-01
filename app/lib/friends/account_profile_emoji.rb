# frozen_string_literal: true
module Friends
  module AccountProfileEmoji
    extend ActiveSupport::Concern

    include Friends::ProfileEmojiExtension

    def profile_emojis
      get_profile_emojis [display_name, note].join(' '), "profile_emojis:account:#{self.id}"
    end
  end
end
