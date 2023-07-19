# frozen_string_literal: true

class AddPrimaryKeyToStatusesTagsJoinTable < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.transaction do
      safety_assured do
        execute 'ALTER TABLE statuses_tags ADD PRIMARY KEY USING INDEX index_statuses_tags_on_tag_id_and_status_id'

        # Rename for consistency as the primary key's name is not represented in db/schema.rb
        execute 'ALTER INDEX index_statuses_tags_on_tag_id_and_status_id RENAME TO statuses_tags_pkey'
      end
    end
  end

  def down
    safety_assured do
      # I have found no way to demote the primary key to an index, instead, re-create the index
      execute 'CREATE UNIQUE INDEX CONCURRENTLY index_statuses_tags_on_tag_id_and_status_id ON statuses_tags (tag_id, status_id)'
      execute 'ALTER TABLE statuses_tags DROP CONSTRAINT statuses_tags_pkey'
    end
  end
end
