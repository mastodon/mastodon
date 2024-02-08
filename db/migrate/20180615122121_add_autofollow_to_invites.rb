# frozen_string_literal: true

class AddAutofollowToInvites < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :invites, :autofollow, :bool, default: false, null: false
    end
  end

  def down
    remove_column :invites, :autofollow
  end
end
