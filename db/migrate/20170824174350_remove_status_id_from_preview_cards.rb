class RemoveStatusIdFromPreviewCards < ActiveRecord::Migration[5.1]
  def change
    remove_column :preview_cards, :status_id, :integer
    add_index :preview_cards, :url, unique: true
  end
end
