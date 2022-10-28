# frozen_string_literal: true

class MigrateCustomFilters < ActiveRecord::Migration[6.1]
  def up
    # Preserve IDs as much as possible to not confuse existing clients.
    # As long as this migration is irreversible, we do not have to deal with conflicts.
    safety_assured do
      execute <<-SQL.squish
        INSERT INTO custom_filter_keywords (id, custom_filter_id, keyword, whole_word, created_at, updated_at)
        SELECT id, id, phrase, whole_word, created_at, updated_at
        FROM custom_filters
      SQL
    end
  end

  def down
    # Copy back changes from custom filters guaranteed to be from the old API
    safety_assured do
      execute <<-SQL.squish
        UPDATE custom_filters
        SET phrase = custom_filter_keywords.keyword, whole_word = custom_filter_keywords.whole_word
        FROM custom_filter_keywords
        WHERE custom_filters.id = custom_filter_keywords.id AND custom_filters.id = custom_filter_keywords.custom_filter_id
      SQL
    end

    # Drop every keyword as we can't safely provide a 1:1 mapping
    safety_assured do
      execute <<-SQL.squish
        TRUNCATE custom_filter_keywords RESTART IDENTITY
      SQL
    end
  end
end
