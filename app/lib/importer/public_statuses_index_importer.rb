# frozen_string_literal: true

class Importer::PublicStatusesIndexImporter < Importer::BaseImporter
  def import!
    # Similar to the StatusesIndexImporter, we will process different scopes
    # to import data into the PublicStatusesIndex.
    scopes.each do |scope|
      scope.find_in_batches(batch_size: @batch_size) do |batch|
        in_work_unit(batch.map(&:status_id)) do |status_ids|
          bulk = ActiveRecord::Base.connection_pool.with_connection do
            status_data = Status.includes(:media_attachments, :preloadable_poll)
                                .joins(:account)
                                .where(accounts: { discoverable: true })
                                .where(id: status_ids)
            Chewy::Index::Import::BulkBuilder.new(index, to_index: status_data).bulk_body
          end

          indexed = 0
          deleted = 0

          bulk.map! do |entry|
            if entry[:index]
              indexed += 1
            else
              deleted += 1
            end
            entry
          end

          Chewy::Index::Import::BulkRequest.new(index).perform(bulk)

          [indexed, deleted]
        end
      end
    end

    wait!
  end

  private

  def index
    PublicStatusesIndex
  end

  def scopes
    [
      local_statuses_scope,
    ]
  end

  def local_statuses_scope
    Status.local
          .select('"statuses"."id", COALESCE("statuses"."reblog_of_id", "statuses"."id") AS status_id')
          .joins(:account)
          .where(accounts: { discoverable: true })
          .where(visibility: :public)
  end
end
