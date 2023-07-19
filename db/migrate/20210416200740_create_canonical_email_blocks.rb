# frozen_string_literal: true

class CreateCanonicalEmailBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :canonical_email_blocks do |t|
      t.string :canonical_email_hash, null: false, default: '', index: { unique: true }
      t.belongs_to :reference_account, null: false, foreign_key: { to_table: 'accounts' }

      t.timestamps
    end
  end
end
