# frozen_string_literal: true

class CreateDomainBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :domain_blocks do |t|
      t.string :domain, null: false, default: ''
      t.timestamps
    end

    add_index :domain_blocks, :domain, unique: true
  end
end
