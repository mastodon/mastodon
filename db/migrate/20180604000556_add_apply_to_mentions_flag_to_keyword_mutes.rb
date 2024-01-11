# frozen_string_literal: true

require 'mastodon/migration_helpers'

class AddApplyToMentionsFlagToKeywordMutes < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :glitch_keyword_mutes, :apply_to_mentions, :boolean, null: false, default: true
    end
  end

  def down
    remove_column :glitch_keyword_mutes, :apply_to_mentions
  end
end
