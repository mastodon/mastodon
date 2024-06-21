# frozen_string_literal: true

class AddFollowersAndFollowingCountsToAccountRelationshipSeveranceEvents < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :account_relationship_severance_events, bulk: true do |t|
        t.integer :followers_count, default: 0, null: false
        t.integer :following_count, default: 0, null: false
      end
    end
  end
end
