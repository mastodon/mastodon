class ConversationIdsToTimestampIds < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("ALTER TABLE conversations ALTER COLUMN id SET DEFAULT timestamp_id('conversations')")
    end

    Mastodon::Snowflake.ensure_id_sequences_exist
  end

  def down
    execute("LOCK conversations")
    execute("SELECT setval('conversations_id_seq', (SELECT MAX(id) FROM conversations))")
    execute("ALTER TABLE conversations ALTER COLUMN id SET DEFAULT nextval('conversations_id_seq')")
  end
end
