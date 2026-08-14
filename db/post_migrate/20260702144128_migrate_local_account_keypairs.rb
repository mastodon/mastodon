# frozen_string_literal: true

class MigrateLocalAccountKeypairs < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  class Account < ApplicationRecord
    has_many :keypairs, inverse_of: :account

    scope :local, -> { where(domain: nil) }
  end

  class Keypair < ApplicationRecord
    self.inheritance_column = nil

    encrypts :private_key

    belongs_to :account

    enum :type, {
      rsa: 0,
    }, validate: true
  end

  def up
    Account.reset_column_information
    Keypair.reset_column_information

    Account.local.where.not(private_key: nil).in_batches do |accounts|
      Keypair.upsert_all(
        accounts.map do |account|
          {
            type: :rsa,
            account_id: account.id,
            local_fragment: '#main-key',
            public_key: account.public_key,
            private_key: account.private_key,
          }
        end,
        unique_by: [:account_id, :local_fragment]
      )

      accounts.update_all(public_key: '', private_key: nil)
    end

    Account.reset_column_information
    Keypair.reset_column_information
  end

  def down
    Account.reset_column_information
    Keypair.reset_column_information

    Account.local.where(private_key: nil).find_each do |account|
      keypair = account.keypairs.find_by(local_fragment: '#main-key')
      next if keypair.nil?

      account.update(public_key: keypair.public_key, private_key: keypair.private_key)
      keypair.delete
    end

    Account.reset_column_information
    Keypair.reset_column_information
  end
end
