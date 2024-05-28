# frozen_string_literal: true

class AddAttachmentDataToImports < ActiveRecord::Migration[4.2]
  def self.up
    change_table :imports do |t|
      # The following corresponds to `t.attachment :data` in an older version of Paperclip
      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.datetime :data_updated_at
    end
  end

  def self.down
    remove_attachment :imports, :data
  end
end
