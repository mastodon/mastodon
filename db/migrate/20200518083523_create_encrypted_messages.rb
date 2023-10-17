# frozen_string_literal: true

class CreateEncryptedMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :encrypted_messages do |t|
      t.references :device, foreign_key: { on_delete: :cascade }
      t.references :from_account, foreign_key: { to_table: :accounts, on_delete: :cascade }
      t.string :from_device_id, default: '', null: false
      t.integer :type, default: 0, null: false
      t.text :body, default: '', null: false
      t.text :digest, default: '', null: false
      t.text :message_franking, default: '', null: false

      t.timestamps
    end
  end
end
