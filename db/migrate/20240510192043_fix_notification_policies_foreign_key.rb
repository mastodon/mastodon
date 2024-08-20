# frozen_string_literal: true

class FixNotificationPoliciesForeignKey < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE notification_policies
          DROP CONSTRAINT fk_rails_506d62f0da,
          ADD CONSTRAINT fk_rails_506d62f0da
            FOREIGN KEY (account_id)
            REFERENCES accounts(id)
            ON DELETE CASCADE
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE notification_policies
          DROP CONSTRAINT fk_rails_506d62f0da,
          ADD CONSTRAINT fk_rails_506d62f0da
            FOREIGN KEY (account_id)
            REFERENCES accounts(id)
      SQL
    end
  end
end
