# frozen_string_literal: true

class AddSettingsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :settings, :text
  end
end
