class AddTrendableToAccounts < ActiveRecord::Migration[6.1]
  def change
    change_table :accounts, bulk: true do |t|
      t.column :trendable, :boolean
      t.column :reviewed_at, :datetime
      t.column :requested_review_at, :datetime
    end
  end
end
