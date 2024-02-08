# frozen_string_literal: true

class AddOEmbedToPreviewCards < ActiveRecord::Migration[5.0]
  def change
    change_table(:preview_cards, bulk: true) do |t|
      t.column :type, :integer, default: 0, null: false
      t.column :html, :text, null: false, default: ''
      t.column :author_name, :string, null: false, default: ''
      t.column :author_url, :string, null: false, default: ''
      t.column :provider_name, :string, null: false, default: ''
      t.column :provider_url, :string, null: false, default: ''
      t.column :width, :integer, default: 0, null: false
      t.column :height, :integer, default: 0, null: false
    end
  end
end
