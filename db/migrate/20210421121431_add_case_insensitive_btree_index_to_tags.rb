class AddCaseInsensitiveBtreeIndexToTags < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class CorruptionError < StandardError
    def cause
      nil
    end

    def backtrace
      []
    end
  end

  def up
    begin
      safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower_btree ON tags (lower(name) text_pattern_ops)' }
    rescue ActiveRecord::StatementInvalid => e
      remove_index :tags, name: 'index_tags_on_name_lower_btree'
      e = CorruptionError.new('Migration failed because of index corruption, see https://docs.joinmastodon.org/admin/troubleshooting/index-corruption/#fixing') if e.is_a?(ActiveRecord::RecordNotUnique)
      raise e
    end

    remove_index :tags, name: 'index_tags_on_name_lower'
  end

  def down
    safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower ON tags (lower(name))' }
    remove_index :tags, name: 'index_tags_on_name_lower_btree'
  end
end
