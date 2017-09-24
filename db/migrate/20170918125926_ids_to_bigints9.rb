class IdsToBigints9 < ActiveRecord::Migration[5.1]
  def up
    change_column :imports, :account_id, :bigint
    change_column :imports, :id, :bigint
  end

  def down
    change_column :imports, :account_id, :integer
    change_column :imports, :id, :integer
  end
end
