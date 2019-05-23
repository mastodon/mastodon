class AddBlurhashToMediaAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :media_attachments, :blurhash, :string
  end
end
