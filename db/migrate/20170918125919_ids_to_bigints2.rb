class IdsToBigints2 < ActiveRecord::Migration[5.1]
  def up
    change_column :accounts, :id, :bigint
  end

  def down
    change_column :accounts, :id, :integer
  end
end
