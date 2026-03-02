# frozen_string_literal: true

class AddFeaturedEmojiToCustomEmojiCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :custom_emoji_categories, :featured_emoji_id, :bigint, null: true
    add_foreign_key :custom_emoji_categories, :custom_emojis, column: :featured_emoji_id, on_delete: :nullify, validate: false
  end
end
