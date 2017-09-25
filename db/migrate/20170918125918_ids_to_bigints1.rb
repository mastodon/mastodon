class IdsToBigints1 < ActiveRecord::Migration[5.1]
  def up
    change_column :account_domain_blocks, :account_id, :bigint
    change_column :account_domain_blocks, :id, :bigint
  end

  def down
    change_column :account_domain_blocks, :account_id, :integer
    change_column :account_domain_blocks, :id, :integer
  end
end
