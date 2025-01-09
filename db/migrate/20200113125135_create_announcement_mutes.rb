# frozen_string_literal: true

class CreateAnnouncementMutes < ActiveRecord::Migration[5.2]
  def change
    create_table :announcement_mutes do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade, index: false }
      t.belongs_to :announcement, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :announcement_mutes, [:account_id, :announcement_id], unique: true
  end
end
