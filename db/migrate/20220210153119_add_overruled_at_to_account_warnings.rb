# frozen_string_literal: true

class AddOverruledAtToAccountWarnings < ActiveRecord::Migration[6.1]
  def change
    add_column :account_warnings, :overruled_at, :datetime
  end
end
