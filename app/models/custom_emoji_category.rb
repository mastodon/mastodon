# frozen_string_literal: true

class CustomEmojiCategory < ApplicationRecord
  has_many :emojis, class_name: 'CustomEmoji', foreign_key: 'category_id', inverse_of: :category, dependent: nil

  validates :name, presence: true, uniqueness: true
end
