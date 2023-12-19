# frozen_string_literal: true

class AddLanguageToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :language, :string, null: false, default: 'en'
  end
end
