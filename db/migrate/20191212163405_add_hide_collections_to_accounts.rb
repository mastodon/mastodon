# frozen_string_literal: true

class AddHideCollectionsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :hide_collections, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
