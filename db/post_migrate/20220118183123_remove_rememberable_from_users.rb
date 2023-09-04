class RemoveRememberableFromUsers < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :users, :remember_token, :string, null: true, default: nil
      remove_column :users, :remember_created_at, :datetime, null: true, default: nil
    end
  end
end
