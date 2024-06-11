# frozen_string_literal: true

class AddIndexAccountsOnDomainAndId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :accounts, [:domain, :id], name: :index_accounts_on_domain_and_id, algorithm: :concurrently
  end
end
