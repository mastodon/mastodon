# frozen_string_literal: true

class CreateSiteUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :site_uploads do |t|
      t.string :var, default: '', null: false, index: { unique: true }

      # The following corresponds to `t.attachment :file` in an older version of Paperclip
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at

      t.json :meta
      t.timestamps
    end
  end
end
