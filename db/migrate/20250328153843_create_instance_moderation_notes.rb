# frozen_string_literal: true

class CreateInstanceModerationNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :instance_moderation_notes do |t|
      t.string :domain, null: false
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, index: false, null: false
      t.text :content

      t.timestamps

      t.index ['domain'], name: 'index_instance_moderation_notes_on_domain'
    end
  end
end
