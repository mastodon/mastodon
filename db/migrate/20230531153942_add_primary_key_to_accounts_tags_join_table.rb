# frozen_string_literal: true

class AddPrimaryKeyToAccountsTagsJoinTable < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.transaction do
      safety_assured do
        execute 'ALTER TABLE accounts_tags ADD PRIMARY KEY USING INDEX index_accounts_tags_on_tag_id_and_account_id'

        # Rename for consistency as the primary key's name is not represented in db/schema.rb
        execute 'ALTER INDEX index_accounts_tags_on_tag_id_and_account_id RENAME TO accounts_tags_pkey'
      end
    end
  end

  def down
    safety_assured do
      # I have found no way to demote the primary key to an index, instead, re-create the index
      execute 'CREATE UNIQUE INDEX CONCURRENTLY index_accounts_tags_on_tag_id_and_account_id ON accounts_tags (tag_id, account_id)'
      execute 'ALTER TABLE accounts_tags DROP CONSTRAINT accounts_tags_pkey'
    end
  end
end
