class AddIndexableToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :statuses, :indexable, :boolean
  end
end
