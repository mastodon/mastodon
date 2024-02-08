# frozen_string_literal: true

class UpdateFollowRecommendationsToVersion2 < ActiveRecord::Migration[6.1]
  # We're switching from a normal to a materialized view so we need
  # custom `up` and `down` paths.

  def up
    drop_view :follow_recommendations
    create_view :follow_recommendations, version: 2, materialized: true

    # To be able to refresh the view concurrently,
    # at least one unique index is required
    safety_assured { add_index :follow_recommendations, :account_id, unique: true }
  end

  def down
    drop_view :follow_recommendations, materialized: true
    create_view :follow_recommendations, version: 1
  end
end
