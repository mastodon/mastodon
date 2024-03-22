# frozen_string_literal: true

class RemoveRelationshipsCountFromAccountRelationshipSeveranceEvents < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :account_relationship_severance_events, :relationships_count, :integer, default: 0, null: false }
  end
end
