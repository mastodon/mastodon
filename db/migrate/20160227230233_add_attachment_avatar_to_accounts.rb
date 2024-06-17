# frozen_string_literal: true

class AddAttachmentAvatarToAccounts < ActiveRecord::Migration[4.2]
  def self.up
    change_table :accounts do |t|
      # The following corresponds to `t.attachment :avatar` in an older version of Paperclip
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
    end
  end

  def self.down
    remove_attachment :accounts, :avatar
  end
end
