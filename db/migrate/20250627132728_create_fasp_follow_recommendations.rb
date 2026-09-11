# frozen_string_literal: true

class CreateFaspFollowRecommendations < ActiveRecord::Migration[8.0]
  def change
    create_table :fasp_follow_recommendations do |t|
      t.references :requesting_account, null: false, foreign_key: { to_table: :accounts }
      t.references :recommended_account, null: false, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end
end
