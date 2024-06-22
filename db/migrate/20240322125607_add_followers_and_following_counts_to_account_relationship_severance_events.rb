# frozen_string_literal: true

class AddFollowersAndFollowingCountsToAccountRelationshipSeveranceEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :account_relationship_severance_events, :followers_count, :integer, default: 0, null: false
    add_column :account_relationship_severance_events, :following_count, :integer, default: 0, null: false
  end
end
