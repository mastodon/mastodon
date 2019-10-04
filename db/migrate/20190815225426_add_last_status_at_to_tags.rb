class AddLastStatusAtToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :last_status_at, :datetime
    add_column :tags, :last_trend_at, :datetime
  end
end
