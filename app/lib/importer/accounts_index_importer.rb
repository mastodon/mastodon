# frozen_string_literal: true

class Importer::AccountsIndexImporter < Importer::BaseImporter
  def import!
    scope.includes(:account_stat).find_in_batches(batch_size: @batch_size) do |tmp|
      in_work_unit(tmp) do |accounts|
        bulk = Chewy::Index::Import::BulkBuilder.new(index, to_index: accounts).bulk_body

        indexed = bulk.count { |entry| entry[:index] }
        deleted = bulk.count { |entry| entry[:delete] }

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
