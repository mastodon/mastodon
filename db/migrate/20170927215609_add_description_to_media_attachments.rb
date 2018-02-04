class AddDescriptionToMediaAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :media_attachments, :description, :text
  end
end
