# frozen_string_literal: true

class UpdateAccountSummariesToVersion3 < ActiveRecord::Migration[8.0]
  def up
    # First, create a temporary `account_summaries` and populate it.
    # This is the most expensive part.
    create_view :tmp_account_summaries,
                sql_definition: Scenic::Definition.new(:account_summaries, 3).to_sql,
                materialized: true

    rename_index :account_summaries, :index_account_summaries_on_account_id, :tmp_index_account_summaries_on_account_id
    safety_assured { add_index :tmp_account_summaries, :account_id, name: :index_account_summaries_on_account_id, unique: true }

    # Then, drop `global_follow_recommendations` and `account_summaries`
    # Downtime starts here but should hopefuly be pretty short.
    drop_view :global_follow_recommendations, materialized: true
    drop_view :account_summaries, materialized: true

    # Then rename `tmp_account_summaries` to `account_summaries`
    safety_assured { execute('ALTER MATERIALIZED VIEW tmp_account_summaries RENAME TO account_summaries') }

    # Then re-create `global_follow_recommendations`, populating it
    create_view :global_follow_recommendations, version: 1, materialized: true
    safety_assured { add_index :global_follow_recommendations, :account_id, unique: true }
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
