# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexStatusesUri < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :statuses, 'index_statuses_on_uri', :uri, unique: true, where: 'uri IS NOT NULL', opclass: :text_pattern_ops
  end

  def down
    update_index :statuses, 'index_statuses_on_uri', :uri, unique: true
  end
end
