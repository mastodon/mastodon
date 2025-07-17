# frozen_string_literal: true

class CreateUsernameBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :username_blocks do |t|
      t.string :username, null: false
      t.string :normalized_username, null: false
      t.boolean :exact, null: false, default: false
      t.boolean :allow_with_approval, null: false, default: false

      t.timestamps
    end

    add_index :username_blocks, 'lower(username)', unique: true, name: 'index_username_blocks_on_username_lower_btree'
    add_index :username_blocks, :normalized_username

    reversible do |dir|
      dir.up do
        load Rails.root.join('db', 'seeds', '05_blocked_usernames.rb')
      end
    end
  end
end
