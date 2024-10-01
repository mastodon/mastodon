# frozen_string_literal: true

class ChangeTagSearchIndexToBtree < ActiveRecord::Migration[5.1]
  def up
    remove_index :tags, name: :hashtag_search_index
    execute 'CREATE INDEX hashtag_search_index ON tags (name text_pattern_ops);'
  end

  def down
    remove_index :tags, name: :hashtag_search_index
    execute 'CREATE INDEX hashtag_search_index ON tags USING gin(to_tsvector(\'simple\', tags.name));'
  end
end
