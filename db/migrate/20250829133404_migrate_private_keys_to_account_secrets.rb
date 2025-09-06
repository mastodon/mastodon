# frozen_string_literal: true

class MigratePrivateKeysToAccountSecrets < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    Account.where.not(private_key: nil).in_batches do |batch|
      batch.each do |account|
        AccountSecret.create!(
          account_id: account.id,
          private_key: account.private_key
        )
      end
    end
  end

  def down
    AccountSecret.delete_all
  end
end
