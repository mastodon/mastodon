class IdsToBigints5 < ActiveRecord::Migration[5.1]
  def up
    change_column :domain_blocks, :id, :bigint
  end

  def down
    change_column :domain_blocks, :id, :integer
  end
end
