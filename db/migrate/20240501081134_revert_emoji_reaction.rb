# frozen_string_literal: true

class RevertEmojiReaction < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :favourites, :emoji, :text
      remove_column :status_stats, :emoji_count, :jsonb
    end
  end
end
