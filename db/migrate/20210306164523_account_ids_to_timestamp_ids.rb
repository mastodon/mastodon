# frozen_string_literal: true

class AccountIdsToTimestampIds < ActiveRecord::Migration[5.2]
  def up
    # Set up the accounts.id column to use our timestamp-based IDs.
    safety_assured do
      execute("ALTER TABLE accounts ALTER COLUMN id SET DEFAULT timestamp_id('accounts')")
    end

    # Make sure we have a sequence to use.
    Mastodon::Snowflake.ensure_id_sequences_exist
  end

  def down
    execute('LOCK accounts')
    execute("SELECT setval('accounts_id_seq', (SELECT MAX(id) FROM accounts))")
    execute("ALTER TABLE accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq')")
  end
end
