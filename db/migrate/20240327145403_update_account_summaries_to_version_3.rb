# frozen_string_literal: true

class UpdateAccountSummariesToVersion3 < ActiveRecord::Migration[6.1]
  def up
    reapplication_global_follow_recommendations_v1 do
      drop_view :account_summaries, materialized: true
      create_view :account_summaries, version: 3, materialized: { no_data: true }
      safety_assured { add_index :account_summaries, :account_id, unique: true }
    end
  end

  def down
    reapplication_global_follow_recommendations_v1 do
      drop_view :account_summaries, materialized: true
      create_view :account_summaries, version: 2, materialized: { no_data: true }
      safety_assured { add_index :account_summaries, :account_id, unique: true }
    end
  end

  def reapplication_global_follow_recommendations_v1
    drop_view :global_follow_recommendations, materialized: true
    yield
    create_view :global_follow_recommendations, version: 1, materialized: { no_data: true }
    safety_assured { add_index :global_follow_recommendations, :account_id, unique: true }
  end
end
