class EncryptedMessageIdsToTimestampIds < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute("ALTER TABLE encrypted_messages ALTER COLUMN id SET DEFAULT timestamp_id('encrypted_messages')")
    end
  end

  def down
    execute('LOCK encrypted_messages')
    execute("SELECT setval('encrypted_messages_id_seq', (SELECT MAX(id) FROM encrypted_messages))")
    execute("ALTER TABLE encrypted_messages ALTER COLUMN id SET DEFAULT nextval('encrypted_messages_id_seq')")
  end
end
