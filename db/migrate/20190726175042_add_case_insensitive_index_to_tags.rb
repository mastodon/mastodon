class AddCaseInsensitiveIndexToTags < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Tag.connection.select_all('SELECT string_agg(id::text, \',\') AS ids FROM tags GROUP BY lower(name) HAVING count(*) > 1').to_ary.each do |row|
      canonical_tag_id  = row['ids'].split(',').first
      redundant_tag_ids = row['ids'].split(',')[1..-1]

      safety_assured do
        execute "UPDATE accounts_tags AS t0 SET tag_id = #{canonical_tag_id} WHERE tag_id IN (#{redundant_tag_ids.join(', ')}) AND NOT EXISTS (SELECT t1.tag_id FROM accounts_tags AS t1 WHERE t1.tag_id = #{canonical_tag_id} AND t1.account_id = t0.account_id)"
        execute "UPDATE statuses_tags AS t0 SET tag_id = #{canonical_tag_id} WHERE tag_id IN (#{redundant_tag_ids.join(', ')}) AND NOT EXISTS (SELECT t1.tag_id FROM statuses_tags AS t1 WHERE t1.tag_id = #{canonical_tag_id} AND t1.status_id = t0.status_id)"
        execute "UPDATE featured_tags AS t0 SET tag_id = #{canonical_tag_id} WHERE tag_id IN (#{redundant_tag_ids.join(', ')})  AND NOT EXISTS (SELECT t1.tag_id FROM featured_tags AS t1 WHERE t1.tag_id = #{canonical_tag_id} AND t1.account_id = t0.account_id)"
      end

      Tag.where(id: redundant_tag_ids).in_batches.delete_all
    end

    begin
      safety_assured { execute 'CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_name_lower ON tags (lower(name))' }
    rescue ActiveRecord::StatementInvalid
      remove_index :tags, name: 'index_tags_on_name_lower'
      raise
    end

    remove_index :tags, name: 'index_tags_on_name'
    remove_index :tags, name: 'hashtag_search_index'
  end

  def down
    add_index :tags, :name, unique: true, algorithm: :concurrently
    safety_assured { execute 'CREATE INDEX CONCURRENTLY hashtag_search_index ON tags (name text_pattern_ops)' }
    remove_index :tags, name: 'index_tags_on_name_lower'
  end
end
