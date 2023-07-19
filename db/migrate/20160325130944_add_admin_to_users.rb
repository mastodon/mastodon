# frozen_string_literal: true

class AddAdminToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean, default: false
  end
end
