# frozen_string_literal: true

class RemoveWholeWordFromCustomFilters < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_column :custom_filters, :whole_word
    end
  end

  def down
    safety_assured do
      add_column :custom_filters, :whole_word, :boolean, default: true, null: false
    end
  end
end
