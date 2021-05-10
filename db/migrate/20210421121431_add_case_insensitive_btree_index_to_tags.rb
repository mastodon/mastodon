class AddCaseInsensitiveBtreeIndexToTags < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower_btree ON tags (lower(name) text_pattern_ops)' }
    remove_index :tags, name: 'index_tags_on_name_lower'
  end

  def down
    safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower ON tags (lower(name))' }
    remove_index :tags, name: 'index_tags_on_name_lower_btree'
  end
end
