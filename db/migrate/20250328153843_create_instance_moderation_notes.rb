# frozen_string_literal: true

class CreateInstanceModerationNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :instance_moderation_notes do |t|
      t.string :domain, null: false
      t.references :account, null: false, foreign_key: true
      t.text :content

      t.timestamps

      t.index ['domain'], name: 'index_instance_moderation_notes_on_domain'
    end
  end
end
