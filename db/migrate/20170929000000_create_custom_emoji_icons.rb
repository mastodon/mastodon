class CreateCustomEmojiIcons < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up { safety_assured { execute 'TRUNCATE custom_emojis' } }
    end

    create_table :custom_emoji_icons do |t|
      t.column :uri, :string
      t.column :image_remote_url, :string
      t.attachment :image
      t.index :uri, unique: true
    end

    remove_attachment :custom_emojis, :image
    add_belongs_to :custom_emojis, :custom_emoji_icon, foreign_key: { on_delete: :cascade, on_update: :cascade }, null: false

    reversible do |dir|
      dir.down { safety_assured { execute 'TRUNCATE custom_emojis' } }
    end
  end
end
