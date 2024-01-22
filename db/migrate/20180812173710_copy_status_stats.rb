# frozen_string_literal: true

class CopyStatusStats < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      if supports_upsert?
        up_fast
      else
        up_slow
      end
    end
  end

  def down
    # Nothing
  end

  private

  def supports_upsert?
    ActiveRecord::Base.connection.database_version >= 90_500
  end

  def up_fast
    say 'Upsert is available, importing counters using the fast method'

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

  def up_slow
    say 'Upsert is not available in PostgreSQL below 9.5, falling back to slow import of counters'

    # We cannot use bulk INSERT or overarching transactions here because of possible
    # uniqueness violations that we need to skip over
    Status.unscoped.select('id, reblogs_count, favourites_count, created_at, updated_at').find_each do |status|
      params = [status.id, status.reblogs_count, status.favourites_count, status.created_at, status.updated_at]
      exec_insert('INSERT INTO status_stats (status_id, reblogs_count, favourites_count, created_at, updated_at) VALUES ($1, $2, $3, $4, $5)', nil, params)
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end
end
