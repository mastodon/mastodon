module Friends
  module ProfileEmoji
    module AccountExtension
      extend ActiveSupport::Concern

      def profile_emojis
        @profile_emojis ||= Friends::ProfileEmoji::Emoji.from_text(emojifiable_text)
      end

      def all_emojis
        emojis + profile_emojis
      end
    end
  end
end
