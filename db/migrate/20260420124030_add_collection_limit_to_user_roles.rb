# frozen_string_literal: true

class AddCollectionLimitToUserRoles < ActiveRecord::Migration[8.1]
  def change
    add_column :user_roles, :collection_limit, :integer, null: false, default: 10
  end
end
