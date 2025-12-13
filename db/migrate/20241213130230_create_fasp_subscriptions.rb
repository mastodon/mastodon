# frozen_string_literal: true

class CreateFaspSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :fasp_subscriptions do |t|
      t.string :category, null: false
      t.string :subscription_type, null: false
      t.integer :max_batch_size, null: false
      t.integer :threshold_timeframe
      t.integer :threshold_shares
      t.integer :threshold_likes
      t.integer :threshold_replies
      t.references :fasp_provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
