class GroupIdsToTimestampIds < ActiveRecord::Migration[5.1]
  def up
    # Set up the accounts.id column to use our timestamp-based IDs.
    safety_assured do
      execute("ALTER TABLE groups ALTER COLUMN id SET DEFAULT timestamp_id('groups')")
    end

    # Make sure we have a sequence to use.
    Mastodon::Snowflake.ensure_id_sequences_exist
  end

  def down
    execute("LOCK groups")
    execute("SELECT setval('groups_id_seq', (SELECT MAX(id) FROM groups))")
    execute("ALTER TABLE groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq')")
  end
end
