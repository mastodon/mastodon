class AddLinkTypeToPreviewCards < ActiveRecord::Migration[6.1]
  def change
    add_column :preview_cards, :link_type, :int
  end
end
