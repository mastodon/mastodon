module Friends
  module ProfileEmoji
    module StatusExtension
      extend ActiveSupport::Concern

      def profile_emojis
        return @profile_emojis if defined?(@profile_emojis)

        fields = [spoiler_text, text]
        fields += preloadable_poll.options unless preloadable_poll.nil?

        @profile_emojis = Friends::ProfileEmoji::Emoji.from_text(fields.join(' '), account.domain)
      end

      def all_emojis
        emojis + profile_emojis
      end
    end
  end
end
