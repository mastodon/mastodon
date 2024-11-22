# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexMediaAttachmentsShortcode < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :media_attachments, 'index_media_attachments_on_shortcode', :shortcode, unique: true, where: 'shortcode IS NOT NULL', opclass: :text_pattern_ops
  end

  def down
    update_index :media_attachments, 'index_media_attachments_on_shortcode', :shortcode, unique: true
  end
end
