class ChangeUserIdNonnullable < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column_null :invites, :user_id, false
      change_column_null :web_settings, :user_id, false
    end
  end
end
