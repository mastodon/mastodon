class AddProcessingToMediaAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :media_attachments, :processing, :integer
  end
end
