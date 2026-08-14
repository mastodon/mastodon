# frozen_string_literal: true

class ChangeAccountUriDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :accounts, :uri, from: '', to: nil
  end
end
