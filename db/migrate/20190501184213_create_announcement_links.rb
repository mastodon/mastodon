class CreateAnnouncementLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :announcement_links do |t|
      t.references :announcement, foreign_key: { on_delete: :cascade }, null: false
      t.string :text, null: false, default: ''
      t.string :url, null: false, default: ''
      t.timestamps
    end
  end
end
