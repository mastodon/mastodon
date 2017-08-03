module Friends
  module FavouriteTagsExtension
    extend ActiveSupport::Concern

    included do |m|
      m.has_many :favourite_tags
    end
  end
end
