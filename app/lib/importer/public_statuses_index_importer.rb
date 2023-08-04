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
      local_mentions_scope,
      local_favourites_scope,
      local_votes_scope,
      local_bookmarks_scope,
    ]
  end

  def local_mentions_scope
    Mention.where(account: Account.local, silent: false)
           .joins(status: :account)
           .where(accounts: { discoverable: true })
           .where(statuses: { visibility: :public })
           .select('mentions.id, statuses.id AS status_id')
  end

  def local_favourites_scope
    Favourite.where(account: Account.local)
             .joins(status: :account)
             .where(accounts: { discoverable: true })
             .where(statuses: { visibility: :public })
             .select('favourites.id, statuses.id AS status_id')
  end

  def local_bookmarks_scope
    Bookmark.joins(status: :account)
            .where(accounts: { discoverable: true })
            .where(statuses: { visibility: :public })
            .select('bookmarks.id, statuses.id AS status_id')
  end

  def local_votes_scope
    local_account_ids = Account.where(discoverable: true).pluck(:id)

    Poll.joins(:votes)
        .where(poll_votes: { account_id: local_account_ids })
        .where(status_id: Status.where(visibility: :public))
  end

  def local_statuses_scope
    Status.local
          .select('"statuses"."id", COALESCE("statuses"."reblog_of_id", "statuses"."id") AS status_id')
          .joins(:account)
          .where(accounts: { discoverable: true })
          .where(visibility: :public)
  end
end
