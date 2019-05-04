module Friends
  module ProfileEmoji
    module SerializerExtension
      extend ActiveSupport::Concern

      included do
        has_many :profile_emojis, serializer: REST::CustomEmojiSerializer
        has_many :all_emojis, serializer: REST::CustomEmojiSerializer
      end
    end
  end
end
