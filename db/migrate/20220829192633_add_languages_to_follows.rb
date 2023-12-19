# frozen_string_literal: true

class AddLanguagesToFollows < ActiveRecord::Migration[6.1]
  def change
    add_column :follows, :languages, :string, array: true
  end
end
