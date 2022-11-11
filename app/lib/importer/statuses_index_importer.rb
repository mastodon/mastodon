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
          bulk = ActiveRecord::Base.connection_pool.with_connection do
            Chewy::Index::Import::BulkBuilder.new(index, to_index: Status.includes(:media_attachments, :preloadable_poll).where(id: status_ids)).bulk_body
          end

          indexed = 0
          deleted = 0

          # We can't use the delete_if proc to do the filtering because delete_if
          # is called before rendering the data and we need to filter based
          # on the results of the filter, so this filtering happens here instead
          bulk.map! do |entry|
            new_entry = begin
              if entry[:index] && entry.dig(:index, :data, 'searchable_by').blank?
                { delete: entry[:index].except(:data) }
              else
                entry
              end
            end

            if new_entry[:index]
              indexed += 1
            else
              deleted += 1
            end

            new_entry
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
    Status.local.select('id, coalesce(reblog_of_id, id) as status_id')
  end
end
