# frozen_string_literal: true

class FixAccountWarningActions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute 'UPDATE account_warnings SET action = 1000 WHERE action = 1'
      execute 'UPDATE account_warnings SET action = 2000 WHERE action = 2'
      execute 'UPDATE account_warnings SET action = 3000 WHERE action = 3'
      execute 'UPDATE account_warnings SET action = 4000 WHERE action = 4'
    end
  end

  def down
    safety_assured do
      execute 'UPDATE account_warnings SET action = 1 WHERE action = 1000'
      execute 'UPDATE account_warnings SET action = 2 WHERE action = 2000'
      execute 'UPDATE account_warnings SET action = 3 WHERE action = 3000'
      execute 'UPDATE account_warnings SET action = 4 WHERE action = 4000'
    end
  end
end
