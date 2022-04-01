require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddCaseInsensitiveBtreeIndexToTags < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    begin
      safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower_btree ON tags (lower(name) text_pattern_ops)' }
    rescue ActiveRecord::StatementInvalid => e
      remove_index :tags, name: 'index_tags_on_name_lower_btree'
      raise CorruptionError.new('index_tags_on_name_lower_btree') if e.is_a?(ActiveRecord::RecordNotUnique)
      raise e
    end

    remove_index :tags, name: 'index_tags_on_name_lower'
  end

  def down
    safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower ON tags (lower(name))' }
    remove_index :tags, name: 'index_tags_on_name_lower_btree'
  end
end
