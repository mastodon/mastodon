class AddAppealedAtToAccountWarnings < ActiveRecord::Migration[6.1]
  def change
    add_column :account_warnings, :appealed_at, :datetime
  end
end
