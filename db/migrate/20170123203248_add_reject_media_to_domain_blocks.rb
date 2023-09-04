class AddRejectMediaToDomainBlocks < ActiveRecord::Migration[5.0]
  def change
    add_column :domain_blocks, :reject_media, :boolean
  end
end
