class CreateBlockMutes < ActiveRecord::Migration[5.0]
  def change
    create_table "block_mutes", force: :casecade do |t|
      t.integer  "account_id",        null: false
      t.integer  "target_account_id", null: false
      t.boolean  "block",             null: false
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
    end

    add_column       :blocks, :block, :boolean, null: false
    execute          "ALTER TABLE blocks ADD CONSTRAINT check_mutes_on_block CHECK(block = TRUE), INHERIT block_mutes"
    Block.update_all block: true

    add_column       :mutes, :block, :boolean, null: false
    execute          "ALTER TABLE mutes ADD CONSTRAINT check_mutes_on_block CHECK(block = FALSE), INHERIT block_mutes"
    Mute.update_all block: false
  end
end
