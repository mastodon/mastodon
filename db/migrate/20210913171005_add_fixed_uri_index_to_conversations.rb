require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddFixedUriIndexToConversations < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    begin
      safety_assured { add_index :conversations, :uri, name: 'index_conversations_on_uri_btree', opclass: :text_pattern_ops, unique: true, algorithm: :concurrently }
    rescue ActiveRecord::StatementInvalid => e
      remove_index :conversations, name: 'index_conversations_on_uri_btree'
      raise CorruptionError if e.is_a?(ActiveRecord::RecordNotUnique)
      raise e
    end

    remove_index :conversations, name: 'index_conversations_on_uri'
  end

  def down
    safety_assured { add_index :conversations, :uri, name: 'index_conversations_on_uri', unique: true, algorithm: :concurrently }
    remove_index :conversations, name: 'index_conversations_on_uri_btree'
  end
end
