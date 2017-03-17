class AddSearchIndexToAccounts < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE INDEX search_index ON accounts USING gin((setweight(to_tsvector(\'simple\', accounts.display_name), \'A\') || setweight(to_tsvector(\'simple\', accounts.username), \'B\') || setweight(to_tsvector(\'simple\', coalesce(accounts.domain, \'\')), \'C\')));'
  end

  def down
    remove_index :accounts, name: :search_index
  end
end
