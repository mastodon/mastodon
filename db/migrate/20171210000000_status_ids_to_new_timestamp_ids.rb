class StatusIdsToNewTimestampIds < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    # Define the temporary function used in this migration.
    Mastodon::Snowflake::define_timestamp_id 'temporary_timestamp_id'

    # Set up the statuses.id column to use the temporary function.
    ActiveRecord::Base.connection.execute(<<~SQL)
      ALTER TABLE statuses
      ALTER COLUMN id
      SET DEFAULT temporary_timestamp_id('statuses', now())
    SQL

    # Replace the function we will use to generate IDs.
    Rake::Task['db:define_timestamp_id'].execute

    # Set up the statuses.id column to use our new timestamp-based IDs.
    ActiveRecord::Base.connection.execute(<<~SQL)
      ALTER TABLE statuses
      ALTER COLUMN id
      SET DEFAULT timestamp_id('statuses', now())
    SQL

    ActiveRecord::Base.connection.execute 'DROP FUNCTION temporary_timestamp_id'
  end
end
