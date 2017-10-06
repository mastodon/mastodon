class AddApprovedToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :approved_at, :datetime
  end
end
