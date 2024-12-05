# frozen_string_literal: true

class RemoveLegacyUserSettingsData < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM settings
      WHERE
        thing_type IS NOT NULL
        AND thing_id IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
