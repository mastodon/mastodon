class IdsToBigints24 < ActiveRecord::Migration[5.1]
  def up
    change_column :web_settings, :id, :bigint
    change_column :web_settings, :user_id, :bigint
  end

  def down
    change_column :web_settings, :id, :integer
    change_column :web_settings, :user_id, :integer
  end
end
