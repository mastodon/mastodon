class AddCaseInsensitiveIndexToTags < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower ON tags (lower(name))' }
    remove_index :tags, name: 'index_tags_on_name'
    remove_index :tags, name: 'hashtag_search_index'
  end

  def down
    add_index :tags, :name, unique: true, algorithm: :concurrently
    safety_assured { execute 'CREATE INDEX CONCURRENTLY hashtag_search_index ON tags (name text_pattern_ops)' }
    remove_index :tags, name: 'index_tags_on_name_lower'
  end
end
