class AddDeletedAtToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :deleted_at, :datetime
  end
end
