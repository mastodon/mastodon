# frozen_string_literal: true

class AddSensitizedToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :sensitized_at, :datetime
  end
end
