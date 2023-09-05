# frozen_string_literal: true

class FixCustomFilterKeywordsIdSeq < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    # 20220613110711 manually inserts items with set `id` in the database, but
    # we also need to bump the sequence number, otherwise
    safety_assured do
      execute <<-SQL.squish
        BEGIN;
        LOCK TABLE custom_filter_keywords IN EXCLUSIVE MODE;
        SELECT setval('custom_filter_keywords_id_seq'::regclass, id) FROM custom_filter_keywords ORDER BY id DESC LIMIT 1;
        COMMIT;
      SQL
    end
  end

  def down; end
end
