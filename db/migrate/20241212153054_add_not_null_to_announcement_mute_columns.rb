# frozen_string_literal: true

class AddNotNullToAnnouncementMuteColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM announcement_mutes
      WHERE account_id IS NULL
      OR announcement_id IS NULL
    SQL

    safety_assured do
      change_column_null :announcement_mutes, :account_id, false
      change_column_null :announcement_mutes, :announcement_id, false
    end
  end

  def down
    safety_assured do
      change_column_null :announcement_mutes, :account_id, true
      change_column_null :announcement_mutes, :announcement_id, true
    end
  end
end
