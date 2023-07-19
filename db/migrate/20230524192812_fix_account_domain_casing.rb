# frozen_string_literal: true

class FixAccountDomainCasing < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute 'UPDATE accounts SET domain = lower(domain) WHERE domain IS NOT NULL AND domain != lower(domain)'
    end
  end

  def down; end
end
