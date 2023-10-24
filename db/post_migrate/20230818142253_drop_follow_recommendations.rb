# frozen_string_literal: true

class DropFollowRecommendations < ActiveRecord::Migration[7.0]
  def up
    drop_view :follow_recommendations, materialized: true
  end

  def down
    create_view :follow_recommendations, version: 2, materialized: { no_data: true }
    safety_assured { add_index :follow_recommendations, :account_id, unique: true }
  end
end
