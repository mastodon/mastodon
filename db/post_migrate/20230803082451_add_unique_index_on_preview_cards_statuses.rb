# frozen_string_literal: true

class AddUniqueIndexOnPreviewCardsStatuses < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :preview_cards_statuses, [:status_id, :preview_card_id], name: :preview_cards_statuses_pkey, algorithm: :concurrently, unique: true
  rescue ActiveRecord::RecordNotUnique
    deduplicate_and_reindex!
  end

  def down
    remove_index :preview_cards_statuses, name: :preview_cards_statuses_pkey
  end

  private

  def supports_concurrent_reindex?
    @supports_concurrent_reindex ||= begin
      ActiveRecord::Base.connection.database_version >= 120_000
    end
  end

  def deduplicate_and_reindex!
    deduplicate_preview_cards!

    if supports_concurrent_reindex?
      safety_assured { execute 'REINDEX INDEX CONCURRENTLY preview_cards_statuses_pkey' }
    else
      remove_index :preview_cards_statuses, name: :preview_cards_statuses_pkey
      add_index :preview_cards_statuses, [:status_id, :preview_card_id], name: :preview_cards_statuses_pkey, algorithm: :concurrently, unique: true
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def deduplicate_preview_cards!
    # Statuses should have only one preview card at most, even if that's not the database
    # constraint we will end up with
    duplicate_ids = select_all('SELECT status_id FROM preview_cards_statuses GROUP BY status_id HAVING count(*) > 1;').rows

    duplicate_ids.each_slice(1000) do |ids|
      # This one is tricky: since we don't have primary keys to keep only one record,
      # use the physical `ctid`
      safety_assured do
        execute "DELETE FROM preview_cards_statuses p WHERE p.status_id IN (#{ids.join(', ')}) AND p.ctid NOT IN (SELECT q.ctid FROM preview_cards_statuses q WHERE q.status_id = p.status_id LIMIT 1)"
      end
    end
  end
end
