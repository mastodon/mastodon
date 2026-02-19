# frozen_string_literal: true

class AddMissingDeleteCascadeAccountModerationNotes < ActiveRecord::Migration[7.2]
  def up
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE account_moderation_notes
          DROP CONSTRAINT fk_rails_3f8b75089b,
          ADD CONSTRAINT fk_rails_3f8b75089b
            FOREIGN KEY (account_id)
            REFERENCES accounts(id)
            ON DELETE CASCADE
      SQL

      execute <<~SQL.squish
        ALTER TABLE account_moderation_notes
          DROP CONSTRAINT fk_rails_dd62ed5ac3,
          ADD CONSTRAINT fk_rails_dd62ed5ac3
            FOREIGN KEY (target_account_id)
            REFERENCES accounts(id)
            ON DELETE CASCADE
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE account_moderation_notes
          DROP CONSTRAINT fk_rails_3f8b75089b,
          ADD CONSTRAINT fk_rails_3f8b75089b
            FOREIGN KEY (account_id)
            REFERENCES accounts(id)
      SQL

      execute <<~SQL.squish
        ALTER TABLE account_moderation_notes
          DROP CONSTRAINT fk_rails_dd62ed5ac3,
          ADD CONSTRAINT fk_rails_dd62ed5ac3
            FOREIGN KEY (target_account_id)
            REFERENCES accounts(id)
      SQL
    end
  end
end
