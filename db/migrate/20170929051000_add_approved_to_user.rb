class AddApprovedToUser < ActiveRecord::Migration[5.1]
  def change 
    add_column :users, :approval_sent_at, :datetime
    add_column :users, :approved_at, :datetime
    add_column :users, :approved_by, :integer
  end
end
