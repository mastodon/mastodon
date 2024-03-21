# frozen_string_literal: true

require_relative '20240312105620_create_severed_relationships'

class RevertCreateSeveredRelationships < ActiveRecord::Migration[7.1]
  def change
    revert CreateSeveredRelationships
  end
end
