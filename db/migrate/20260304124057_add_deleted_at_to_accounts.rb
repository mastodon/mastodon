# frozen_string_literal: true

class AddDeletedAtToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :deleted_at, :datetime
  end
end
