class IncreaseBackupSize < ActiveRecord::Migration[5.2]
  def up
    change_column :backups, :dump_file_size, :bigint
  end

  def down
    change_column :backups, :dump_file_size, :integer
  end
end
