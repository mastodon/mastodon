# frozen_string_literal: true

class AddPrimaryKeyToPreviewCardsStatusesJoinTable < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute 'ALTER TABLE preview_cards_statuses ADD PRIMARY KEY USING INDEX preview_cards_statuses_pkey'
    end
  end

  def down
    safety_assured do
      # I have found no way to demote the primary key to an index, instead, re-create the index
      execute 'CREATE UNIQUE INDEX CONCURRENTLY preview_cards_statuses_pkey_tmp ON preview_cards_statuses (status_id, preview_card_id)'
      execute 'ALTER TABLE preview_cards_statuses DROP CONSTRAINT preview_cards_statuses_pkey'
      execute 'ALTER INDEX preview_cards_statuses_pkey_tmp RENAME TO preview_cards_statuses_pkey'
    end
  end
end
