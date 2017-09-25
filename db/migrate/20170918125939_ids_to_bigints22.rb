class IdsToBigints22 < ActiveRecord::Migration[5.1]
  def up
    change_column :tags, :id, :bigint
  end

  def down
    change_column :tags, :id, :integer
  end
end
