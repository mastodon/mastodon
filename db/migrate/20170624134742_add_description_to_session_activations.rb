class AddDescriptionToSessionActivations < ActiveRecord::Migration[5.1]
  def change
    change_table :session_activations, bulk: true do |t|
      t.column :user_agent, :string, null: false, default: ''
      t.column :ip, :inet
      t.foreign_key :users, on_delete: :cascade
    end
  end
end
