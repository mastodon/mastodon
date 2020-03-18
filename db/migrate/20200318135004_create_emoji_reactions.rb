class CreateEmojiReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :emoji_reactions do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade, index: false }
      t.belongs_to :status, foreign_key: { on_delete: :cascade }

      t.string :name, null: false, default: ''

      t.timestamps
    end

    add_index :emoji_reactions, [:account_id, :status_id, :name], unique: true, name: :index_emoji_reactions_on_account_id_and_status_id
  end
end

