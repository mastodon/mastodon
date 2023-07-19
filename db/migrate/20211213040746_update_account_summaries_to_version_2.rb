# frozen_string_literal: true

class UpdateAccountSummariesToVersion2 < ActiveRecord::Migration[6.1]
  def up
    reapplication_follow_recommendations_v2 do
      drop_view :account_summaries, materialized: true
      create_view :account_summaries, version: 2, materialized: { no_data: true }
      safety_assured { add_index :account_summaries, :account_id, unique: true }
    end
  end

  def down
    reapplication_follow_recommendations_v2 do
      drop_view :account_summaries, materialized: true
      create_view :account_summaries, version: 1, materialized: { no_data: true }
      safety_assured { add_index :account_summaries, :account_id, unique: true }
    end
  end

  def reapplication_follow_recommendations_v2
    drop_view :follow_recommendations, materialized: true
    yield
    create_view :follow_recommendations, version: 2, materialized: { no_data: true }
    safety_assured { add_index :follow_recommendations, :account_id, unique: true }
  end
end
