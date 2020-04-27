class AddCapabilitiesToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :usable, :boolean
    add_column :tags, :trendable, :boolean
    add_column :tags, :listable, :boolean
    add_column :tags, :reviewed_at, :datetime
    add_column :tags, :requested_review_at, :datetime
  end
end
