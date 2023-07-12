# frozen_string_literal: true

class CreateSystemKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :system_keys do |t|
      t.binary :key

      t.timestamps
    end
  end
end
