# frozen_string_literal: true

class CreateCustomEmojiCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_emoji_categories do |t|
      t.string :name, index: { unique: true }

      t.timestamps
    end
  end
end
