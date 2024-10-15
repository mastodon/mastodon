# frozen_string_literal: true

class AddEmojiReactionCountToStatusStat < ActiveRecord::Migration[7.0]
  def change
    add_column :status_stats, :emoji_count, :jsonb
  end
end
