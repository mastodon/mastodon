# frozen_string_literal: true

class CreateGlobalFollowRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_view :global_follow_recommendations, materialized: { no_data: true }
    safety_assured { add_index :global_follow_recommendations, :account_id, unique: true }
  end
end
