class AddDummyPasswordFlagToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :dummy_password_flag, :boolean, default: false, null: false
  end
end
