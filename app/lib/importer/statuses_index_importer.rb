# frozen_string_literal: true

class Importer::StatusesIndexImporter < Importer::BaseImporter
  def import!
    # The idea is that instead of iterating over all statuses in the database
    # and calculating the searchable_by for each of them (majority of which
    # would be empty), we approach the index from the other end

    scopes.each do |scope|
      # We could be tempted to keep track of status IDs we have already processed
      # from a different scope to avoid indexing them multiple times, but that
      # could end up being a very large array

      scope.find_in_batches(batch_size: @batch_size) do |tmp|
        in_work_unit(tmp.map(&:status_id)) do |status_ids|
          deleted = 0

          bulk = ActiveRecord::Base.connection_pool.with_connection do
            to_index = index.adapter.default_scope.where(id: status_ids)
            crutches = Chewy::Index::Crutch::Crutches.new index, to_index
            to_index.map do |object|
              # This is unlikely to happen, but the post may have been
              # un-interacted with since it was queued for indexing
              if object.searchable_by.empty?
                deleted += 1
                { delete: { _id: object.id } }
              else
                { index: { _id: object.id, data: index.compose(object, crutches, fields: []) } }
              end
            end
          end

          indexed = bulk.size - deleted

          Chewy::Index::Import::BulkRequest.new(index).perform(bulk)

          [indexed, deleted]
        end
      end
    end

    wait!
  end

  private

  def index
    StatusesIndex
  end

  def scopes
    [
      local_statuses_scope,
      local_mentions_scope,
      local_favourites_scope,
      local_votes_scope,
      local_bookmarks_scope,
    ]
  end

  def local_mentions_scope
    Mention.where(account: Account.local, silent: false).select(:id, :status_id)
  end

  def local_favourites_scope
    Favourite.where(account: Account.local).select(:id, :status_id)
  end

  def local_bookmarks_scope
    Bookmark.select(:id, :status_id)
  end

  def local_votes_scope
    Poll.joins(:votes).where(votes: { account: Account.local }).select('polls.id, polls.status_id')
  end

  def local_statuses_scope
    Status.local.select('"statuses"."id", COALESCE("statuses"."reblog_of_id", "statuses"."id") AS status_id')
  end
end
