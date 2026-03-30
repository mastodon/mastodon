# frozen_string_literal: true

class AddAvatarDescriptionToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :avatar_description, :string, null: false, default: ''
  end
end
