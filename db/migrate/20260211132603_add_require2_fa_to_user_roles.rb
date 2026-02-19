# frozen_string_literal: true

class AddRequire2FaToUserRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :user_roles, :require_2fa, :boolean, null: false, default: false
  end
end
