# frozen_string_literal: true

class FixNotificationPermissionForeignKeys < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE notification_permissions
          DROP CONSTRAINT fk_rails_7c0bed08df,
          ADD CONSTRAINT fk_rails_7c0bed08df
            FOREIGN KEY (account_id)
            REFERENCES accounts(id)
            ON DELETE CASCADE,

          DROP CONSTRAINT fk_rails_e3e0aaad70,
          ADD CONSTRAINT fk_rails_e3e0aaad70
            FOREIGN KEY (from_account_id)
            REFERENCES accounts(id)
            ON DELETE CASCADE
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE notification_permissions
          DROP CONSTRAINT fk_rails_7c0bed08df,
          ADD CONSTRAINT fk_rails_7c0bed08df
            FOREIGN KEY (account_id)
            REFERENCES accounts(id),

          DROP CONSTRAINT fk_rails_e3e0aaad70,
          ADD CONSTRAINT fk_rails_e3e0aaad70
            FOREIGN KEY (from_account_id)
            REFERENCES accounts(id)
      SQL
    end
  end
end
