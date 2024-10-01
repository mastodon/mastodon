# frozen_string_literal: true

class AddSearchIndexToAccounts < ActiveRecord::Migration[5.0]
  def up
    execute <<~SQL.squish
      CREATE INDEX search_index
      ON accounts
      USING gin(
        (
          setweight(to_tsvector('simple', accounts.display_name), 'A') ||
          setweight(to_tsvector('simple', accounts.username), 'B') ||
          setweight(to_tsvector('simple', coalesce(accounts.domain, '')), 'C')
        )
      )
    SQL
  end

  def down
    remove_index :accounts, name: :search_index
  end
end
