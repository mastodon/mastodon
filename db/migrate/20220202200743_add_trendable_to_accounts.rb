# frozen_string_literal: true

class AddTrendableToAccounts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table(:accounts, bulk: true) do |t|
        t.column :trendable, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
        t.column :reviewed_at, :datetime
        t.column :requested_review_at, :datetime
      end
    end
  end
end
