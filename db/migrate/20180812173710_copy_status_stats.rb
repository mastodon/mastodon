class CopyStatusStats < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL.squish
        INSERT INTO status_stats (status_id, reblogs_count, favourites_count)
        SELECT id, reblogs_count, favourites_count
        FROM statuses
        ON CONFLICT (status_id) DO UPDATE
        SET reblogs_count = EXCLUDED.reblogs_count, favourites_count = EXCLUDED.favourites_count
      SQL
    end
  end

  def down
    # Nothing
  end
end
