# frozen_string_literal: true

class ChangeRelaysEnabled < ActiveRecord::Migration[5.2]
  def up
    # The relays table is supposed to be very small,
    # single-digit number of rows, so this should be fine
    safety_assured do
      add_column :relays, :state, :integer, default: 0, null: false

      # At the time of this migration, no relays reject anyone, so if
      # there are enabled ones, they are accepted
      execute 'UPDATE relays SET state = 2 WHERE enabled = true'
      remove_column :relays, :enabled
    end
  end

  def down
    change_table(:relays, bulk: true) do |t|
      t.remove :state
      t.column :enabled, :boolean, default: false, null: false
    end
  end
end
