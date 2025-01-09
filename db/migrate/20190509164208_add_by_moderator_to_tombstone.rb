# frozen_string_literal: true

class AddByModeratorToTombstone < ActiveRecord::Migration[5.2]
  def change
    add_column :tombstones, :by_moderator, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
