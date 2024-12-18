# frozen_string_literal: true

class AddDisabledToCustomEmojis < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :custom_emojis, :disabled, :bool, default: false, null: false }
  end

  def down
    remove_column :custom_emojis, :disabled
  end
end
