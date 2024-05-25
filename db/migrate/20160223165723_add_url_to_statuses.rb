# frozen_string_literal: true

class AddURLToStatuses < ActiveRecord::Migration[4.2]
  def change
    add_column :statuses, :url, :string, null: true, default: nil
  end
end
