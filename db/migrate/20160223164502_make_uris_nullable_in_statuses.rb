# frozen_string_literal: true

class MakeUrisNullableInStatuses < ActiveRecord::Migration[4.2]
  def change
    change_column :statuses, :uri, :string, null: true, default: nil
  end
end
