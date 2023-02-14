class AddIsExclusiveToLists < ActiveRecord::Migration[6.1]
  def change
    add_column :lists, :exclusive, :boolean
    change_column_default :lists, :exclusive, false
  end
end
