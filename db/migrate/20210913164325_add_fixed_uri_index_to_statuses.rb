require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddFixedUriIndexToStatuses < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    begin
      safety_assured { add_index :statuses, :uri, name: 'index_statuses_on_uri_btree', opclass: :text_pattern_ops, unique: true, algorithm: :concurrently }
    rescue ActiveRecord::StatementInvalid => e
      remove_index :statuses, name: 'index_statuses_on_uri_btree'
      raise CorruptionError if e.is_a?(ActiveRecord::RecordNotUnique)
      raise e
    end

    remove_index :statuses, name: 'index_statuses_on_uri'
  end

  def down
    safety_assured { add_index :statuses, :uri, name: 'index_statuses_on_uri', unique: true, algorithm: :concurrently }
    remove_index :statuses, name: 'index_statuses_on_uri_btree'
  end
end
