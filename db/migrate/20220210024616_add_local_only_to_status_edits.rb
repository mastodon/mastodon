class AddLocalOnlyToStatusEdits < ActiveRecord::Migration[6.1]
  def change
    add_column :status_edits, :local_only, :boolean
  end
end
