# frozen_string_literal: true

class RemoveDefaultLanguageFromStatuses < ActiveRecord::Migration[5.1]
  def change
    change_column :statuses, :language, :string, default: nil, null: true
  end
end
