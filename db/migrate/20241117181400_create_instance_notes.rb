# frozen_string_literal: true

class CreateInstanceNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :instance_notes do |t|
      t.string :domain
      t.bigint :account_id
      t.text :content

      t.timestamps

      t.index ['domain'], name: 'index_instance_notes_on_domain'
    end
  end
end
