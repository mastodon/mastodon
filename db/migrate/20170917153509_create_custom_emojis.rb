# frozen_string_literal: true

class CreateCustomEmojis < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_emojis do |t|
      t.string :shortcode, null: false, default: ''
      t.string :domain

      # The following corresponds to `t.attachment :image` in an older version of Paperclip
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end

    add_index :custom_emojis, [:shortcode, :domain], unique: true
  end
end
