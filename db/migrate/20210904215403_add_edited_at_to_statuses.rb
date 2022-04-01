class AddEditedAtToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :statuses, :edited_at, :datetime
  end
end
