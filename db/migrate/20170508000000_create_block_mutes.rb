class CreateBlockMutes < ActiveRecord::Migration[5.0]
  def change
    create_table "block_mutes", id: false, force: :casecade do |t|
      t.integer  "account_id",        null: false
      t.integer  "target_account_id", null: false
      t.boolean  "block",             null: false
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
    end

    reversible do |dir|
      dir.up do
        add_column       :blocks, :block, :boolean
        Block.update_all block: true
        change_column    :blocks, :block, :boolean, default: true, null: false
        execute          "ALTER TABLE blocks ADD CONSTRAINT check_blocks_on_block CHECK(block = TRUE), INHERIT block_mutes"

        add_column       :mutes, :block, :boolean
        Mute.update_all  block: false
        change_column    :mutes, :block, :boolean, default: false, null: false
        execute          "ALTER TABLE mutes ADD CONSTRAINT check_mutes_on_block CHECK(block = FALSE), INHERIT block_mutes"
      end

      dir.down do
        execute       "ALTER TABLE blocks NO INHERIT block_mutes, DROP CONSTRAINT check_blocks_on_block"
        remove_column :blocks, :block

        execute       "ALTER TABLE mutes NO INHERIT block_mutes, DROP CONSTRAINT check_mutes_on_block"
        remove_column :mutes, :block
      end
    end
  end
end
