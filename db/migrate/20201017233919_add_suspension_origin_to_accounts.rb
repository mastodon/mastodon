# frozen_string_literal: true

class AddSuspensionOriginToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :suspension_origin, :integer
  end
end
