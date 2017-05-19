class AddExternalToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :external, :boolean, null: false, default: false
  end
end
