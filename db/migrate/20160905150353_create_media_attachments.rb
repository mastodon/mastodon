# frozen_string_literal: true

class CreateMediaAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :media_attachments do |t|
      t.integer :status_id, null: true, default: nil
      t.attachment :file
      t.string :remote_url, null: false, default: ''
      t.integer :account_id

      t.timestamps
    end

    add_index :media_attachments, :status_id
  end
end
