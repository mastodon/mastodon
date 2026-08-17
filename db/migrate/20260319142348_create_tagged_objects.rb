# frozen_string_literal: true

class CreateTaggedObjects < ActiveRecord::Migration[8.1]
  def change
    create_table :tagged_objects do |t|
      t.references :status, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :object, polymorphic: true, null: true
      t.string :ap_type, null: false
      t.string :uri

      t.timestamps
    end

    add_index :tagged_objects, [:status_id, :object_type, :object_id], unique: true, where: 'object_type IS NOT NULL AND object_id IS NOT NULL'
    add_index :tagged_objects, [:status_id, :uri], unique: true, where: 'uri IS NOT NULL'
  end
end
