class CreateFollowRecommendationSuppressions < ActiveRecord::Migration[6.1]
  def change
    create_table :follow_recommendation_suppressions do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }

      t.timestamps
    end
  end
end
