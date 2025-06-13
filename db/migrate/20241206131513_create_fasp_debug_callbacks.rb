# frozen_string_literal: true

class CreateFaspDebugCallbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :fasp_debug_callbacks do |t|
      t.references :fasp_provider, null: false, foreign_key: true
      t.string :ip, null: false
      t.text :request_body, null: false

      t.timestamps
    end
  end
end
