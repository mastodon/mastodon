class AddTrendableToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :trendable, :boolean
    add_column :accounts, :reviewed_at, :datetime
    add_column :accounts, :requested_review_at, :datetime
  end
end
