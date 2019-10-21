# frozen_string_literal: true

# == Schema Information
#
# Table name: custom_emoji_categories
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CustomEmojiCategory < ApplicationRecord
  has_many :emojis, class_name: 'CustomEmoji', foreign_key: 'category_id', inverse_of: :category

  validates :name, presence: true, uniqueness: true
end
