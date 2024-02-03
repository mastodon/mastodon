# frozen_string_literal: true

class BulkImportService < BaseService
  def call(import)
    @import  = import
    @account = @import.account

    case @import.type.to_sym
    when :following
      import_follows!
    when :blocking
      import_blocks!
    when :muting
      import_mutes!
    when :domain_blocking
      import_domain_blocks!
    when :bookmarks
      import_bookmarks!
    when :lists
      import_lists!
    end

    @import.update!(state: :finished, finished_at: Time.now.utc) if @import.processed_items == @import.total_items
  rescue
    @import.update!(state: :finished, finished_at: Time.now.utc)

    raise
  end

  private

  def extract_rows_by_acct
    local_domain_suffix = "@#{Rails.configuration.x.local_domain}"
    @import.rows.to_a.index_by { |row| row.data['acct'].delete_suffix(local_domain_suffix) }
  end

  def import_follows!
    rows_by_acct = extract_rows_by_acct

    if @import.overwrite?
      @account.following.reorder(nil).find_each do |followee|
        row = rows_by_acct.delete(followee.acct)

        if row.nil?
          UnfollowService.new.call(@account, followee)
        else
          row.destroy
          @import.processed_items += 1
          @import.imported_items += 1

          # Since we're updating the settings of an existing relationship, we can safely call
          # FollowService directly
          FollowService.new.call(@account, followee, reblogs: row.data['show_reblogs'], notify: row.data['notify'], languages: row.data['languages'])
        end
      end

      # Save pending infos due to `overwrite?` handling
      @import.save!
    end

    Import::RowWorker.push_bulk(rows_by_acct.values) do |row|
      [row.id]
    end
  end

  def import_blocks!
    rows_by_acct = extract_rows_by_acct

    if @import.overwrite?
      @account.blocking.reorder(nil).find_each do |blocked_account|
        row = rows_by_acct.delete(blocked_account.acct)

        if row.nil?
          UnblockService.new.call(@account, blocked_account)
        else
          row.destroy
          @import.processed_items += 1
          @import.imported_items += 1
          BlockService.new.call(@account, blocked_account)
        end
      end

      # Save pending infos due to `overwrite?` handling
      @import.save!
    end

    Import::RowWorker.push_bulk(rows_by_acct.values) do |row|
      [row.id]
    end
  end

  def import_mutes!
    rows_by_acct = extract_rows_by_acct

    if @import.overwrite?
      @account.muting.reorder(nil).find_each do |muted_account|
        row = rows_by_acct.delete(muted_account.acct)

        if row.nil?
          UnmuteService.new.call(@account, muted_account)
        else
          row.destroy
          @import.processed_items += 1
          @import.imported_items += 1
          MuteService.new.call(@account, muted_account, notifications: row.data['hide_notifications'])
        end
      end

      # Save pending infos due to `overwrite?` handling
      @import.save!
    end

    Import::RowWorker.push_bulk(rows_by_acct.values) do |row|
      [row.id]
    end
  end

  def import_domain_blocks!
    domains = @import.rows.map { |row| row.data['domain'] }

    if @import.overwrite?
      @account.domain_blocks.find_each do |domain_block|
        domain = domains.delete(domain_block)

        @account.unblock_domain!(domain_block.domain) if domain.nil?
      end
    end

    @import.rows.delete_all
    domains.each { |domain| @account.block_domain!(domain) }
    @import.update!(processed_items: @import.total_items, imported_items: @import.total_items)

    AfterAccountDomainBlockWorker.push_bulk(domains) do |domain|
      [@account.id, domain]
    end
  end

  def import_bookmarks!
    rows_by_uri = @import.rows.index_by { |row| row.data['uri'] }

    if @import.overwrite?
      @account.bookmarks.includes(:status).find_each do |bookmark|
        row = rows_by_uri.delete(ActivityPub::TagManager.instance.uri_for(bookmark.status))

        if row.nil?
          bookmark.destroy!
        else
          row.destroy
          @import.processed_items += 1
          @import.imported_items += 1
        end
      end

      # Save pending infos due to `overwrite?` handling
      @import.save!
    end

    Import::RowWorker.push_bulk(rows_by_uri.values) do |row|
      [row.id]
    end
  end

  def import_lists!
    rows = @import.rows.to_a
    included_lists = rows.map { |row| row.data['list_name'] }.uniq

    if @import.overwrite?
      @account.owned_lists.where.not(title: included_lists).destroy_all

      # As list membership changes do not retroactively change timeline
      # contents, simplify things by just clearing everything
      @account.owned_lists.find_each do |list|
        list.list_accounts.destroy_all
      end
    end

    included_lists.each do |title|
      @account.owned_lists.find_or_create_by!(title: title)
    end

    Import::RowWorker.push_bulk(rows) do |row|
      [row.id]
    end
  end
end
