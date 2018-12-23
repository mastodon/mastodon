class StatusIdsToTimestampIds < ActiveRecord::Migration[5.1]
  def up
    # Prepare the function we will use to generate IDs.
    Rake::Task['db:define_timestamp_id'].execute

    # Set up the statuses.id column to use our timestamp-based IDs.
    ActiveRecord::Base.connection.execute(<<~SQL)
      ALTER TABLE statuses
      ALTER COLUMN id
      SET DEFAULT timestamp_id('statuses')
    SQL

    # Make sure we have a sequence to use.
    Rake::Task['db:ensure_id_sequences_exist'].execute
  end

  def down
    # Revert the column to the old method of just using the sequence
    # value for new IDs. Set the current ID sequence to the maximum
    # existing ID, such that the next sequence will be one higher.

    # We lock the table during this so that the ID won't get clobbered,
    # but ID is indexed, so this should be a fast operation.
    ActiveRecord::Base.connection.execute(<<~SQL)
      LOCK statuses;
      SELECT setval('statuses_id_seq', (SELECT MAX(id) FROM statuses));
      ALTER TABLE statuses
        ALTER COLUMN id
        SET DEFAULT nextval('statuses_id_seq');
    SQL
  end
end
