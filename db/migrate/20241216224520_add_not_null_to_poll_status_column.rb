# frozen_string_literal: true

class AddNotNullToPollStatusColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :polls, 'status_id IS NOT NULL', name: 'polls_status_id_null', validate: false
  end
end
