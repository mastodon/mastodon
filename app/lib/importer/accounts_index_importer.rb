# frozen_string_literal: true

class Importer::AccountsIndexImporter < Importer::BaseImporter
  def import!
    scope.includes(:account_stat).find_in_batches(batch_size: @batch_size) do |tmp|
      in_work_unit(tmp) do |accounts|
        bulk = build_bulk_body(accounts)

        indexed = bulk.size
        deleted = 0

        Chewy::Index::Import::BulkRequest.new(index).perform(bulk)

        [indexed, deleted]
      end
    end

    wait!
  end

  private

  def index
    AccountsIndex
  end

  def scope
    Account.searchable
  end
end
