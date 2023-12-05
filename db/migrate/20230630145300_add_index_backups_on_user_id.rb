# frozen_string_literal: true

class AddIndexBackupsOnUserId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :backups, :user_id, algorithm: :concurrently
  end
end
