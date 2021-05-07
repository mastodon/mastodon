class CreateFollowRecommendations < ActiveRecord::Migration[5.2]
  def change
    create_view :follow_recommendations
  end
end
