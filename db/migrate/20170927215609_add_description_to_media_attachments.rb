class AddDescriptionToMediaAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :media_attachments, :description, :text
  end
end
