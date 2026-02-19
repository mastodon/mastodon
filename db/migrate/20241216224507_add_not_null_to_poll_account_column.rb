# frozen_string_literal: true

class AddNotNullToPollAccountColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :polls, 'account_id IS NOT NULL', name: 'polls_account_id_null', validate: false
  end
end
