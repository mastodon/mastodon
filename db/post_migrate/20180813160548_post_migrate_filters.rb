class PostMigrateFilters < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    drop_table :glitch_keyword_mutes if table_exists? :glitch_keyword_mutes
  end

  def down
  end
end

