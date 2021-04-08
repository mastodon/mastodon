class MediaAttachmentIdsToTimestampIds < ActiveRecord::Migration[5.1]
  def up
    # Set up the media_attachments.id column to use our timestamp-based IDs.
    safety_assured do
      execute("ALTER TABLE media_attachments ALTER COLUMN id SET DEFAULT timestamp_id('media_attachments')")
    end

    # Make sure we have a sequence to use.
    Mastodon::Snowflake.ensure_id_sequences_exist
  end

  def down
    execute("LOCK media_attachments")
    execute("SELECT setval('media_attachments_id_seq', (SELECT MAX(id) FROM media_attachments))")
    execute("ALTER TABLE media_attachments ALTER COLUMN id SET DEFAULT nextval('media_attachments_id_seq')")
  end
end
