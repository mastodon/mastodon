# frozen_string_literal: true

class AddWholeWordToCustomFilter < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_column :custom_filters, :whole_word, :boolean, default: true, null: false
    end
  end

  def down
    remove_column :custom_filters, :whole_word
  end
end
