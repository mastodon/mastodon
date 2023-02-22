# frozen_string_literal: true

class AddIndexFeaturedTagsOnAccountIdAndTagId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    duplicates = FeaturedTag.connection.select_all('SELECT string_agg(id::text, \',\') AS ids FROM featured_tags GROUP BY account_id, tag_id HAVING count(*) > 1').to_ary

    duplicates.each do |row|
      FeaturedTag.where(id: row['ids'].split(',')[0...-1]).destroy_all
    end

    add_index :featured_tags, [:account_id, :tag_id], unique: true, algorithm: :concurrently
    remove_index :featured_tags, [:account_id], algorithm: :concurrently
  end

  def down
    add_index :featured_tags, [:account_id], algorithm: :concurrently
    remove_index :featured_tags, [:account_id, :tag_id], unique: true, algorithm: :concurrently
  end
end
