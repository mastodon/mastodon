# frozen_string_literal: true

class AddSilentToMentions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :mentions,
        :silent,
        :boolean,
        null: false,
        default: false
      )
    end
  end

  def down
    remove_column :mentions, :silent
  end
end
