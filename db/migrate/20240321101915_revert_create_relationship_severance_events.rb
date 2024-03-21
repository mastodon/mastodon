# frozen_string_literal: true

require_relative '20240312100644_create_relationship_severance_events'

class RevertCreateRelationshipSeveranceEvents < ActiveRecord::Migration[7.1]
  def change
    revert CreateRelationshipSeveranceEvents
  end
end
