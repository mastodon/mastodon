# frozen_string_literal: true

class FixFeaturedTagsConstraints < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute 'DELETE FROM featured_tags WHERE tag_id IS NULL'
      change_column_null :featured_tags, :tag_id, false
      execute 'DELETE FROM featured_tags WHERE account_id IS NULL'
      change_column_null :featured_tags, :account_id, false
    end
  end

  def down
    safety_assured do
      change_column_null :featured_tags, :tag_id, true
      change_column_null :featured_tags, :account_id, true
    end
  end
end
