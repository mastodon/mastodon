module Friends
  module FavouriteTagsExtension
    extend ActiveSupport::Concern

    included do
      has_many :favourite_tags
      after_create :add_default_favourite_tag

      DEFAULT_TAGS = [
        "みんなのP名刺",
        "imas_img",
        "ダイマストドン",
      ].freeze

      def add_default_favourite_tag
        DEFAULT_TAGS.each_with_index do |tag_name, i|
          self.favourite_tags.create!(visibility: 'public', tag: Tag.find_or_create_by!(name: tag_name), order: i)
        end
      end

    end
  end
end
