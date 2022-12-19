class DropSubscriptions < ActiveRecord::Migration[5.2]
  def up
    drop_table :subscriptions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
