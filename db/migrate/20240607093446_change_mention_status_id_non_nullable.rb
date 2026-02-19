# frozen_string_literal: true

class ChangeMentionStatusIdNonNullable < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :mentions, 'status_id IS NOT NULL', name: 'mentions_status_id_null', validate: false
  end
end
