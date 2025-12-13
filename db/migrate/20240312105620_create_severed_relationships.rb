# frozen_string_literal: true

class CreateSeveredRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :severed_relationships do |t|
      # No need to have an index on this foreign key as it is covered by `index_severed_relationships_on_unique_tuples`
      t.references :relationship_severance_event, null: false, foreign_key: { on_delete: :cascade }, index: false

      # No need to have an index on this foregin key as it is covered by `index_severed_relationships_on_local_account_and_event`
      t.references :local_account, null: false, foreign_key: { to_table: :accounts, on_delete: :cascade }, index: false
      t.references :remote_account, null: false, foreign_key: { to_table: :accounts, on_delete: :cascade }

      # Used to describe whether `local_account` is the active (follower) or passive (followed) part of the relationship
      t.integer :direction, null: false

      # Those attributes are carried over from the `follows` table
      # rubocop:disable Rails/ThreeStateBooleanColumn
      t.boolean :show_reblogs
      t.boolean :notify
      # rubocop:enable Rails/ThreeStateBooleanColumn
      t.string :languages, array: true

      t.timestamps

      t.index [:relationship_severance_event_id, :local_account_id, :direction, :remote_account_id], name: 'index_severed_relationships_on_unique_tuples', unique: true
      t.index [:local_account_id, :relationship_severance_event_id], name: 'index_severed_relationships_on_local_account_and_event'
    end
  end
end
