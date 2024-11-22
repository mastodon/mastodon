# frozen_string_literal: true

class AddRoleIdToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured { add_reference :users, :role, foreign_key: { to_table: 'user_roles', on_delete: :nullify }, index: false }
    add_index :users, :role_id, algorithm: :concurrently, where: 'role_id IS NOT NULL'
  end
end
