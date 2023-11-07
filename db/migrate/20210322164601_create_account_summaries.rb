# frozen_string_literal: true

class CreateAccountSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :account_summaries, materialized: { no_data: true }

    # To be able to refresh the view concurrently,
    # at least one unique index is required
    safety_assured { add_index :account_summaries, :account_id, unique: true }
  end
end
