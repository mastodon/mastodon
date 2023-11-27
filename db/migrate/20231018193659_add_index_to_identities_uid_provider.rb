# frozen_string_literal: true

class AddIndexToIdentitiesUidProvider < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM identities
          WHERE id NOT IN (
          SELECT DISTINCT ON(uid, provider) id FROM identities
          ORDER BY uid, provider, id ASC
        )
      SQL
    end

    add_index :identities, [:uid, :provider], unique: true, algorithm: :concurrently
  end

  def down
    remove_index :identities, [:uid, :provider]
  end
end
