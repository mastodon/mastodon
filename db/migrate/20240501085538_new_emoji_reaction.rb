# frozen_string_literal: true

class NewEmojiReaction < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :favourites, :emoji, :text
    add_reference :favourites, :custom_emoji, index: { algorithm: :concurrently }
    add_column :status_stats, :emoji_count, :jsonb
  end
end
