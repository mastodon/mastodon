class AddLastWebfingeredAtToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :last_webfingered_at, :datetime
  end
end
