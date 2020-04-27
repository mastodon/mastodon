class CreateAnnouncementReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :announcement_reactions do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade, index: false }
      t.belongs_to :announcement, foreign_key: { on_delete: :cascade }

      t.string :name, null: false, default: ''
      t.belongs_to :custom_emoji, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :announcement_reactions, [:account_id, :announcement_id, :name], unique: true, name: :index_announcement_reactions_on_account_id_and_announcement_id
  end
end
