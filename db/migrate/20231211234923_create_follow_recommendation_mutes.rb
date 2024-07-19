# frozen_string_literal: true

class CreateFollowRecommendationMutes < ActiveRecord::Migration[7.1]
  def change
    create_table :follow_recommendation_mutes do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :target_account, null: false, foreign_key: { to_table: 'accounts', on_delete: :cascade }

      t.timestamps
    end

    add_index :follow_recommendation_mutes, [:account_id, :target_account_id], unique: true
  end
end
