class AddExpiresAtToMutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mutes, :expires_at, :datetime
  end
end
