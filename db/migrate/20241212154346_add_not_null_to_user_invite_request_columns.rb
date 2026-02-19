# frozen_string_literal: true

class AddNotNullToUserInviteRequestColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM user_invite_requests
      WHERE user_id IS NULL
    SQL

    safety_assured { change_column_null :user_invite_requests, :user_id, false }
  end

  def down
    safety_assured { change_column_null :user_invite_requests, :user_id, true }
  end
end
