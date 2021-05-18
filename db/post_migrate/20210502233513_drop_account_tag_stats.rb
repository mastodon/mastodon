# frozen_string_literal: true

class DropAccountTagStats < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    drop_table :account_tag_stats
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
