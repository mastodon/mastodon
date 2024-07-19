# frozen_string_literal: true

class RemoveObsoleteRolesFromUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :users, :admin, :boolean, default: false, null: false }
    safety_assured { remove_column :users, :moderator, :boolean, default: false, null: false }
  end
end
