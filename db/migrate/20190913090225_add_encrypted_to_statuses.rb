class AddEncryptedToStatuses < ActiveRecord::Migration[5.2]
  def change
      add_column :statuses, :encrypted, :bool, null: false, default: false
  end
end
