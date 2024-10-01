# frozen_string_literal: true

class TruncatePreviewCards < ActiveRecord::Migration[5.1]
  def up
    rename_table :preview_cards, :deprecated_preview_cards

    create_table :preview_cards do |t|
      t.string     :url, default: '', null: false, index: { unique: true }
      t.string     :title, default: '', null: false
      t.string     :description, default: '', null: false

      # The following corresponds to `t.attachment :image` in an older version of Paperclip
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

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
    raise ActiveRecord::IrreversibleMigration, 'Previous preview cards table has already been removed' unless ActiveRecord::Base.connection.table_exists? 'deprecated_preview_cards'

    drop_table :preview_cards
    rename_table :deprecated_preview_cards, :preview_cards
  end
end
