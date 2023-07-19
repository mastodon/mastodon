# frozen_string_literal: true

class AddWebauthnIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :webauthn_id, :string
  end
end
