# frozen_string_literal: true

class AddDescriptionToSessionActivations < ActiveRecord::Migration[5.1]
  def change
    change_table(:session_activations, bulk: true) do |t|
      t.column :user_agent, :string, null: false, default: ''
      t.column :ip, :inet
    end
    add_foreign_key :session_activations, :users, on_delete: :cascade
  end
end
