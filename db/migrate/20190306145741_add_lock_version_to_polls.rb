class AddLockVersionToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :lock_version, :integer, null: false, default: 0
  end
end

