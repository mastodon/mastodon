# frozen_string_literal: true

class AddUriToRelays < ActiveRecord::Migration[8.1]
  def change
    add_column :relays, :uri, :string, null: false, default: ''
    add_column :relays, :direction, :integer, default: 0, null: false
    add_column :relays, :requires_opt_in, :boolean, default: false, null: false
  end
end
