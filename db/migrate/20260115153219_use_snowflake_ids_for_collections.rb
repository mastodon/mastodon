# frozen_string_literal: true

class UseSnowflakeIdsForCollections < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute(<<~SQL.squish)
        ALTER TABLE collections ALTER COLUMN id SET DEFAULT timestamp_id('collections');
        ALTER TABLE collection_items ALTER COLUMN id SET DEFAULT timestamp_id('collection_items');
      SQL
    end

    Mastodon::Snowflake.ensure_id_sequences_exist
  end

  def down
    execute(<<~SQL.squish)
      LOCK collections;
      SELECT setval('collections_id_seq', (SELECT MAX(id) FROM collections));
      ALTER TABLE collections ALTER COLUMN id SET DEFAULT nextval('collections_id_seq');
      LOCK collection_items;
      SELECT setval('collection_items_id_seq', (SELECT MAX(id) FROM collection_items));
      ALTER TABLE collection_items ALTER COLUMN id SET DEFAULT nextval('collection_items_id_seq');
    SQL
  end
end
