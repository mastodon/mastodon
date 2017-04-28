class AddOEmbedToPreviewCards < ActiveRecord::Migration[5.0]
  def change
    add_column :preview_cards, :type, :integer, default: 0, null: false
    add_column :preview_cards, :html, :text, null: false, default: ''
    add_column :preview_cards, :author_name, :string, null: false, default: ''
    add_column :preview_cards, :author_url, :string, null: false, default: ''
    add_column :preview_cards, :provider_name, :string, null: false, default: ''
    add_column :preview_cards, :provider_url, :string, null: false, default: ''
    add_column :preview_cards, :width, :integer, default: 0, null: false
    add_column :preview_cards, :height, :integer, default: 0, null: false
  end
end
