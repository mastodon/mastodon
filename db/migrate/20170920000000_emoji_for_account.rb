class EmojiForAccount < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up { execute 'TRUNCATE custom_emojis' }
    end

    remove_index :custom_emojis, column: [:shortcode, :domain], unique: true
    remove_column :custom_emojis, :domain, :string

    add_belongs_to :custom_emojis, :account, foreign_key: { on_delete: :cascade, on_update: :cascade }, null: false
    add_column :custom_emojis, :href, :string
    add_column :custom_emojis, :uri, :string
    add_index :custom_emojis, [:uri, :account_id], unique: true

    reversible do |dir|
      dir.down { execute 'TRUNCATE custom_emojis' }
    end

    create_table 'emoji_favourites' do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade, on_update: :cascade }, null: false
      t.belongs_to :custom_emoji, foreign_key: { on_delete: :cascade, on_update: :cascade }, null: false
    end

    create_join_table :custom_emojis, :statuses do |t|
      t.index [:status_id, :custom_emoji_id], unique: true
    end

    add_foreign_key :custom_emojis_statuses, :statuses, on_delete: :cascade, on_update: :cascade
    add_foreign_key :custom_emojis_statuses, :custom_emojis, on_delete: :cascade, on_update: :cascade
  end
end
