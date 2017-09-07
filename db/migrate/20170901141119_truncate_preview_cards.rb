class TruncatePreviewCards < ActiveRecord::Migration[5.1]
  def up
    rename_table :preview_cards, :deprecated_preview_cards

    create_table :preview_cards do |t|
      t.string     :url, default: '', null: false, index: { unique: true }
      t.string     :title, default: '', null: false
      t.string     :description, default: '', null: false
      t.attachment :image
      t.integer    :type, default: 0, null: false
      t.text       :html, default: '', null: false
      t.string     :author_name, default: '', null: false
      t.string     :author_url, default: '', null: false
      t.string     :provider_name, default: '', null: false
      t.string     :provider_url, default: '', null: false
      t.integer    :width, default: 0, null: false
      t.integer    :height, default: 0, null: false
      t.timestamps
    end
  end

  def down
    if ActiveRecord::Base.connection.table_exists? 'deprecated_preview_cards'
      drop_table :preview_cards
      rename_table :deprecated_preview_cards, :preview_cards
    else
      raise ActiveRecord::IrreversibleMigration, 'Previous preview cards table has already been removed'
    end
  end
end
