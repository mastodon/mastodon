# frozen_string_literal: true

class ChangeUsersDefaultRoleId < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :role_id, from: nil, to: -99
  end
end
