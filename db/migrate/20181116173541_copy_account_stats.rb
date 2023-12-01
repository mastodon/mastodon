# frozen_string_literal: true

class CopyAccountStats < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class MigrationAccount < ApplicationRecord
    self.table_name = :accounts
  end

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
    version = select_one("SELECT current_setting('server_version_num') AS v")['v'].to_i
    version >= 90_500
  end

  def up_fast
    say 'Upsert is available, importing counters using the fast method'

    MigrationAccount.unscoped.select('id').find_in_batches(batch_size: 5_000) do |accounts|
      execute <<-SQL.squish
        INSERT INTO account_stats (account_id, statuses_count, following_count, followers_count, created_at, updated_at)
        SELECT id, statuses_count, following_count, followers_count, created_at, updated_at
        FROM accounts
        WHERE id IN (#{accounts.map(&:id).join(', ')})
        ON CONFLICT (account_id) DO UPDATE
        SET statuses_count = EXCLUDED.statuses_count, following_count = EXCLUDED.following_count, followers_count = EXCLUDED.followers_count
      SQL
    end
  end

  def up_slow
    say 'Upsert is not available in PostgreSQL below 9.5, falling back to slow import of counters'

    # We cannot use bulk INSERT or overarching transactions here because of possible
    # uniqueness violations that we need to skip over
    MigrationAccount.unscoped.select('id, statuses_count, following_count, followers_count, created_at, updated_at').find_each do |account|
      params = [account.id, account[:statuses_count], account[:following_count], account[:followers_count], account.created_at, account.updated_at]
      exec_insert('INSERT INTO account_stats (account_id, statuses_count, following_count, followers_count, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)', nil, params)
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end
end
