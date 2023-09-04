# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :identities, id: :integer do |t|
      t.references :user, type: :integer, foreign_key: { on_delete: :cascade }
      t.string :provider, null: false, default: ''
      t.string :uid, null: false, default: ''

      t.timestamps
    end
  end
end
