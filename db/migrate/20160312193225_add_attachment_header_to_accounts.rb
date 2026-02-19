# frozen_string_literal: true

class AddAttachmentHeaderToAccounts < ActiveRecord::Migration[4.2]
  def up
    change_table :accounts do |t|
      # The following corresponds to `t.attachment :header` in an older version of Paperclip
      t.string :header_file_name
      t.string :header_content_type
      t.integer :header_file_size
      t.datetime :header_updated_at
    end
  end

  def down
    remove_attachment :accounts, :header
  end
end
