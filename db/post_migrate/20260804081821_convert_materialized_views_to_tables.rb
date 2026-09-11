# frozen_string_literal: true

class ConvertMaterializedViewsToTables < ActiveRecord::Migration[8.1]
  def up
    # Prepare replacement of `account_summaries`
    rename_index :account_summaries, :index_account_summaries_on_account_id, :tmp_index_account_summaries_on_account_id
    rename_index :account_summaries, :idx_on_account_id_language_sensitive_250461e1eb, :tmp_idx_on_account_id_language_sensitive_250461e1eb

    # Create replacement table for `account_summaries`
    create_table :tmp_account_summaries, primary_key: :account_id do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :language
      t.boolean :sensitive, default: false, null: false
    end

    safety_assured do # The table is empty, so blocking is minimal
      add_foreign_key :tmp_account_summaries, :accounts, on_delete: :cascade
      add_index :tmp_account_summaries, [:account_id, :language, :sensitive], name: :idx_on_account_id_language_sensitive_250461e1eb
    end

    # Create replacement table for `global_follow_recommendations`
    rename_index :global_follow_recommendations, :index_global_follow_recommendations_on_account_id, :tmp_index_global_follow_recommendations_on_account_id

    create_table :tmp_global_follow_recommendations, primary_key: :account_id do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.decimal :rank, null: false
      t.string :reason, array: true, null: false
      t.boolean :stale, null: false, default: false
    end

    safety_assured do # The table is empty, so blocking is minimal
      add_foreign_key :tmp_global_follow_recommendations, :accounts, on_delete: :cascade
      add_index :tmp_global_follow_recommendations, :rank, name: :index_global_follow_recommendations_on_rank
    end

    # Fill the tables
    safety_assured do
      execute 'INSERT INTO tmp_account_summaries SELECT account_summaries.* FROM account_summaries INNER JOIN accounts ON accounts.id = account_summaries.account_id' if Scenic.database.populated?('account_summaries')
      execute 'INSERT INTO tmp_global_follow_recommendations SELECT global_follow_recommendations.* FROM global_follow_recommendations INNER JOIN accounts ON accounts.id = global_follow_recommendations.account_id' if Scenic.database.populated?('global_follow_recommendations')
    end

    # Drop and rename
    drop_view :global_follow_recommendations, materialized: true
    safety_assured { rename_table :tmp_global_follow_recommendations, :global_follow_recommendations }

    drop_view :account_summaries, materialized: true
    safety_assured { rename_table :tmp_account_summaries, :account_summaries }
  end

  def down
    drop_table :account_summaries
    create_view :account_summaries, version: 3, materialized: true
    add_index :account_summaries, :account_id, unique: true
    add_index :account_summaries, [:account_id, :language, :sensitive]

    drop_table :global_follow_recommendations
    create_view :global_follow_recommendations, version: 1, materialized: true
    add_index :global_follow_recommendations, :account_id, unique: true
  end
end
