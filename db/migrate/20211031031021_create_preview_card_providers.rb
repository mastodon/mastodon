class CreatePreviewCardProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :preview_card_providers do |t|
      t.string :domain, null: false, default: '', index: { unique: true }
      t.attachment :icon
      t.boolean :trendable
      t.datetime :reviewed_at
      t.datetime :requested_review_at
      t.timestamps
    end
  end
end
