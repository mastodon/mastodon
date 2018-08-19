class CopyStatusStats < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      Status.unscoped.select('id').find_in_batches(batch_size: 5_000) do |statuses|
        execute <<-SQL.squish
          INSERT INTO status_stats (status_id, reblogs_count, favourites_count, created_at, updated_at)
          SELECT id, reblogs_count, favourites_count, created_at, updated_at
          FROM statuses
          WHERE id IN (#{statuses.map(&:id).join(', ')})
          ON CONFLICT (status_id) DO UPDATE
          SET reblogs_count = EXCLUDED.reblogs_count, favourites_count = EXCLUDED.favourites_count
        SQL
      end
    end
  end

  def down
    # Nothing
  end
end
