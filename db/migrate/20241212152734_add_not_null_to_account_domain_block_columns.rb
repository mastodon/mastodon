# frozen_string_literal: true

class AddNotNullToAccountDomainBlockColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM account_domain_blocks
      WHERE account_id IS NULL
      OR domain IS NULL
    SQL

    safety_assured do
      change_column_null :account_domain_blocks, :account_id, false
      change_column_null :account_domain_blocks, :domain, false
    end
  end

  def down
    safety_assured do
      change_column_null :account_domain_blocks, :account_id, true
      change_column_null :account_domain_blocks, :domain, true
    end
  end
end
