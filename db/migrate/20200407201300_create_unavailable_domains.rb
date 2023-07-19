# frozen_string_literal: true

class CreateUnavailableDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :unavailable_domains do |t|
      t.string :domain, default: '', null: false, index: { unique: true }

      t.timestamps
    end
  end
end
