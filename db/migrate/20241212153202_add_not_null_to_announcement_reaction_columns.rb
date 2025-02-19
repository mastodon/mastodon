# frozen_string_literal: true

class AddNotNullToAnnouncementReactionColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM announcement_reactions
      WHERE account_id IS NULL
      OR announcement_id IS NULL
    SQL

    safety_assured do
      change_column_null :announcement_reactions, :account_id, false
      change_column_null :announcement_reactions, :announcement_id, false
    end
  end

  def down
    safety_assured do
      change_column_null :announcement_reactions, :account_id, true
      change_column_null :announcement_reactions, :announcement_id, true
    end
  end
end
