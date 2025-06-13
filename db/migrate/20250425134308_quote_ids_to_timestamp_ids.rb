# frozen_string_literal: true

class QuoteIdsToTimestampIds < ActiveRecord::Migration[8.0]
  def up
    # Set up the media_attachments.id column to use our timestamp-based IDs.
    safety_assured do
      execute("ALTER TABLE quotes ALTER COLUMN id SET DEFAULT timestamp_id('quotes')")
    end

    # Make sure we have a sequence to use.
    Mastodon::Snowflake.ensure_id_sequences_exist
  end

  def down
    execute('LOCK quotes')
    execute("SELECT setval('quotes_id_seq', (SELECT MAX(id) FROM quotes))")
    execute("ALTER TABLE quotes ALTER COLUMN id SET DEFAULT nextval('quotes_id_seq')")
  end
end
