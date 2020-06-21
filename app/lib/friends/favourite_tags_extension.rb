module Friends
  module FavouriteTagsExtension
    extend ActiveSupport::Concern

    included do
      has_many :favourite_tags
      after_create :add_default_favourite_tag

      DEFAULT_TAGS = [
        "デレラジ",
        "デレパ",
        "imas_mor",
        "millionradio",
        "sidem",
      ].freeze

      def add_default_favourite_tag
        DEFAULT_TAGS.each_with_index do |tag_name, i|
          self.favourite_tags.create!(visibility: 'unlisted', tag: Tag.find_or_create_by!(name: tag_name.mb_chars.downcase), order: (DEFAULT_TAGS.length - i))
        end
      end
    end
  end
end
