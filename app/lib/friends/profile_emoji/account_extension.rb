module Friends
  module ProfileEmoji
    module AccountExtension
      extend ActiveSupport::Concern

      included do
        after_commit :clear_avatar_cache
      end

      def profile_emojis
        @profile_emojis ||= Friends::ProfileEmoji::Emoji.from_text(emojifiable_text, domain)
      end

      def all_emojis
        emojis + profile_emojis
      end

      private

      def clear_avatar_cache
        EntityCache.instance.clear_avatar(username, domain)
      end
    end
  end
end
