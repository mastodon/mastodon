# frozen_string_literal: true

class FixCanonicalEmailBlocksForeignKey < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute 'ALTER TABLE canonical_email_blocks DROP CONSTRAINT fk_rails_1ecb262096, ADD CONSTRAINT fk_rails_1ecb262096 FOREIGN KEY (reference_account_id) REFERENCES accounts(id) ON DELETE CASCADE;'
    end
  end

  def down
    safety_assured do
      execute 'ALTER TABLE canonical_email_blocks DROP CONSTRAINT fk_rails_1ecb262096, ADD CONSTRAINT fk_rails_1ecb262096 FOREIGN KEY (reference_account_id) REFERENCES accounts(id);'
    end
  end
end
