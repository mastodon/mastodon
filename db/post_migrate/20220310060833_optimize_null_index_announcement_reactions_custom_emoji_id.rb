# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexAnnouncementReactionsCustomEmojiId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :announcement_reactions, 'index_announcement_reactions_on_custom_emoji_id', :custom_emoji_id, where: 'custom_emoji_id IS NOT NULL'
  end

  def down
    update_index :announcement_reactions, 'index_announcement_reactions_on_custom_emoji_id', :custom_emoji_id
  end
end
