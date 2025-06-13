# frozen_string_literal: true

class AddQuoteIdToStatusEdit < ActiveRecord::Migration[8.0]
  def change
    add_column :status_edits, :quote_id, :bigint, null: true
  end
end
