# frozen_string_literal: true

class DropImports < ActiveRecord::Migration[7.1]
  def up
    drop_table :imports
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
