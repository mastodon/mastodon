# frozen_string_literal: true

class AddDescriptionToSessionActivations < ActiveRecord::Migration[5.1]
  def change
    add_column :session_activations, :user_agent, :string, null: false, default: ''
    add_column :session_activations, :ip, :inet
    add_foreign_key :session_activations, :users, on_delete: :cascade
  end
end
