# frozen_string_literal: true

class AddMissingStatusToBulkImport < ActiveRecord::Migration[8.1]
  def change
    add_column :bulk_imports, :missing_status, :boolean, null: false, default: false
  end
end
