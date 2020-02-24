class RemoveBoostsWideningAudience < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    public_boosts = Status.find_by_sql(<<-SQL)
      SELECT boost.id
      FROM statuses AS boost
      LEFT JOIN statuses AS boosted ON boost.reblog_of_id = boosted.id
      WHERE
        boost.id > 101746055577600000
        AND (boost.local = TRUE OR boost.uri IS NULL)
        AND boost.visibility IN (0, 1)
        AND boost.reblog_of_id IS NOT NULL
        AND boosted.visibility = 2
    SQL

    RemovalWorker.push_bulk(public_boosts.pluck(:id))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
