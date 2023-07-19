# frozen_string_literal: true

class CreateDomainAllows < ActiveRecord::Migration[5.2]
  def change
    create_table :domain_allows do |t|
      t.string :domain, default: '', null: false, index: { unique: true }

      t.timestamps
    end
  end
end
