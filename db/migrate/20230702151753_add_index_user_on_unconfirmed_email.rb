# frozen_string_literal: true

class AddIndexUserOnUnconfirmedEmail < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :users, :unconfirmed_email, where: 'unconfirmed_email IS NOT NULL', algorithm: :concurrently
  end
end
