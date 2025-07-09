# frozen_string_literal: true

class AddNotNullToTombstoneAccountColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :tombstones, 'account_id IS NOT NULL', name: 'tombstones_account_id_null', validate: false
  end
end
