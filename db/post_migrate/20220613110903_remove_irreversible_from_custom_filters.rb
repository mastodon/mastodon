# frozen_string_literal: true

class RemoveIrreversibleFromCustomFilters < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_column :custom_filters, :irreversible
    end
  end

  def down
    safety_assured do
      add_column :custom_filters, :irreversible, :boolean, null: false, default: false
    end
  end
end
