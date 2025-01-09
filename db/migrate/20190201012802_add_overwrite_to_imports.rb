# frozen_string_literal: true

class AddOverwriteToImports < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :imports, :overwrite, :boolean, default: false, null: false
    end
  end

  def down
    remove_column :imports, :overwrite, :boolean
  end
end
