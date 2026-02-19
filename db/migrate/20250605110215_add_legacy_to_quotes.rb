# frozen_string_literal: true

class AddLegacyToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :legacy, :boolean, null: false, default: false
  end
end
