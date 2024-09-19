# frozen_string_literal: true

class RemoveCryptoScopeValues < ActiveRecord::Migration[7.1]
  def up
    applications.in_batches do |records|
      records.update_all(<<~SQL.squish)
        scopes = TRIM(REPLACE(scopes, 'crypto', ''))
      SQL
    end

    tokens.in_batches do |records|
      records.update_all(<<~SQL.squish)
        scopes = TRIM(REPLACE(scopes, 'crypto', ''))
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def applications
    Doorkeeper::Application
      .where("scopes LIKE '%crypto%'")
  end

  def tokens
    Doorkeeper::AccessToken
      .where("scopes LIKE '%crypto%'")
  end
end
