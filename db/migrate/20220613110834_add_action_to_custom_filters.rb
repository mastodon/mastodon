# frozen_string_literal: true

class AddActionToCustomFilters < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :custom_filters, :action, :integer, null: false, default: 0
      execute 'UPDATE custom_filters SET action = 1 WHERE irreversible IS TRUE'
    end
  end

  def down
    execute 'UPDATE custom_filters SET irreversible = (action = 1)'
    remove_column :custom_filters, :action
  end
end
