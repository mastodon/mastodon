# frozen_string_literal: true

class CreateTaggings < ActiveRecord::Migration[7.1]
  def up
    create_taggings

    safety_assured do
      convert_status_taggings
      convert_account_taggings
    end

    drop_table :accounts_tags
    drop_table :statuses_tags
  end

  def down
    restore_join_tables

    safety_assured do
      restore_account_taggings
      restore_status_taggings
    end

    drop_table :taggings
  end

  def create_taggings
    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false

      t.timestamps
    end
  end

  def restore_join_tables
    create_table :statuses_tags, primary_key: [:tag_id, :status_id], force: :cascade do |t|
      t.bigint :status_id, null: false
      t.bigint :tag_id, null: false
      t.index :status_id
    end

    create_table :accounts_tags, primary_key: [:tag_id, :account_id], force: :cascade do |t|
      t.bigint :account_id, null: false
      t.bigint :tag_id, null: false
      t.index [:account_id, :tag_id]
    end
  end

  def convert_status_taggings
    execute <<~SQL.squish
      INSERT INTO taggings(tag_id, taggable_type, taggable_id, created_at, updated_at)
      SELECT statuses_tags.tag_id, 'Status', statuses_tags.status_id, statuses.updated_at, statuses.updated_at
      FROM statuses_tags
      JOIN statuses ON statuses.id = statuses_tags.status_id
    SQL
  end

  def convert_account_taggings
    execute <<~SQL.squish
      INSERT INTO taggings(tag_id, taggable_type, taggable_id, created_at, updated_at)
      SELECT accounts_tags.tag_id, 'Account', accounts_tags.account_id, accounts.updated_at, accounts.updated_at
      FROM accounts_tags
      JOIN accounts ON accounts.id = accounts_tags.account_id
    SQL
  end

  def restore_account_taggings
    execute <<~SQL.squish
      INSERT INTO accounts_tags(account_id, tag_id)
      SELECT taggable_id, tag_id
      FROM taggings
      WHERE taggable_type = 'Account'
    SQL
  end

  def restore_status_taggings
    execute <<~SQL.squish
      INSERT INTO statuses_tags(status_id, tag_id)
      SELECT taggable_id, tag_id
      FROM taggings
      WHERE taggable_type = 'Status'
    SQL
  end
end
