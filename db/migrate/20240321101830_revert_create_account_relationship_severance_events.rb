# frozen_string_literal: true

require_relative '20240320140159_create_account_relationship_severance_events'

class RevertCreateAccountRelationshipSeveranceEvents < ActiveRecord::Migration[7.1]
  def change
    revert CreateAccountRelationshipSeveranceEvents
  end
end
