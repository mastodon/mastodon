class IdsToBigints19 < ActiveRecord::Migration[5.1]
  def up
    change_column :settings, :id, :bigint
    change_column :settings, :thing_id, :bigint
  end

  def down
    change_column :settings, :id, :integer
    change_column :settings, :thing_id, :integer
  end
end
