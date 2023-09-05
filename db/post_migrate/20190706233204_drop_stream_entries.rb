# frozen_string_literal: true

class DropStreamEntries < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    drop_table :stream_entries
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
