# frozen_string_literal: true

class BackfillApprovedAtOnUsers < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute <<~SQL.squish
        UPDATE users
        SET approved_at = created_at
        WHERE approved IS TRUE
        AND approved_at IS NULL
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        UPDATE USERS
        SET approved_at = NULL
        WHERE approved IS TRUE
        AND approved_at IS NOT NULL
      SQL
    end
  end
end
