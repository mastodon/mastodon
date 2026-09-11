# frozen_string_literal: true

class FixGeneratedAnnualReportsForeignKey < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute 'ALTER TABLE generated_annual_reports DROP CONSTRAINT fk_rails_4ca37f035c, ADD CONSTRAINT fk_rails_4ca37f035c FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;'
    end
  end

  def down
    safety_assured do
      execute 'ALTER TABLE generated_annual_reports DROP CONSTRAINT fk_rails_4ca37f035c, ADD CONSTRAINT fk_rails_4ca37f035c FOREIGN KEY (account_id) REFERENCES accounts(id);'
    end
  end
end
