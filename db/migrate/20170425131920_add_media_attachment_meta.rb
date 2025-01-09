# frozen_string_literal: true

class AddMediaAttachmentMeta < ActiveRecord::Migration[5.0]
  def change
    add_column :media_attachments, :file_meta, :json
  end
end
