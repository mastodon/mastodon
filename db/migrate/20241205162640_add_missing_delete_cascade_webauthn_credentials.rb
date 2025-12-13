# frozen_string_literal: true

class AddMissingDeleteCascadeWebauthnCredentials < ActiveRecord::Migration[7.2]
  def up
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE webauthn_credentials
          DROP CONSTRAINT fk_rails_a4355aef77,
          ADD CONSTRAINT fk_rails_a4355aef77
            FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE webauthn_credentials
          DROP CONSTRAINT fk_rails_a4355aef77,
          ADD CONSTRAINT fk_rails_a4355aef77
            FOREIGN KEY (user_id)
            REFERENCES users(id)
      SQL
    end
  end
end
