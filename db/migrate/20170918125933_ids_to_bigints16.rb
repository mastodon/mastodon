class IdsToBigints16 < ActiveRecord::Migration[5.1]
  def up
    change_column :oauth_applications, :id, :bigint
    change_column :oauth_applications, :owner_id, :bigint
  end

  def down
    change_column :oauth_applications, :id, :integer
    change_column :oauth_applications, :owner_id, :integer
  end
end
