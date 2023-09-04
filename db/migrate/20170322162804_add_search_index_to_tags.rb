class AddSearchIndexToTags < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE INDEX hashtag_search_index ON tags USING gin(to_tsvector(\'simple\', tags.name));'
  end

  def down
    remove_index :tags, name: :hashtag_search_index
  end
end
