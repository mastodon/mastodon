# frozen_string_literal: true

class AddHintToRules < ActiveRecord::Migration[7.1]
  def change
    add_column :rules, :hint, :text, null: false, default: ''
  end
end
