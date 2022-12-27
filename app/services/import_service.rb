# frozen_string_literal: true

require 'csv'

class ImportService < BaseService
  ROWS_PROCESSING_LIMIT = 20_000

  def call(import)
    @import  = import
    @account = @import.account

    case @import.type
    when 'following'
      import_follows!
    when 'blocking'
      import_blocks!
    when 'muting'
      import_mutes!
    when 'domain_blocking'
      import_domain_blocks!
    when 'bookmarks'
      import_bookmarks!
    end
  end

  private

  def import_follows!
    parse_import_data!(['Account address'])
    import_relationships!('follow', 'unfollow', @account.following, ROWS_PROCESSING_LIMIT, reblogs: { header: 'Show boosts', default: true }, notify: { header: 'Notify on new posts', default: false }, languages: { header: 'Languages', default: nil })
  end

  def import_blocks!
    parse_import_data!(['Account address'])
    import_relationships!('block', 'unblock', @account.blocking, ROWS_PROCESSING_LIMIT)
  end

  def import_mutes!
    parse_import_data!(['Account address'])
    import_relationships!('mute', 'unmute', @account.muting, ROWS_PROCESSING_LIMIT, notifications: { header: 'Hide notifications', default: true })
  end

  def import_domain_blocks!
    parse_import_data!(['#domain'])
    items = @data.take(ROWS_PROCESSING_LIMIT).map { |row| row['#domain'].strip }

    if @import.overwrite?
      presence_hash = items.index_with(true)

      @account.domain_blocks.find_each do |domain_block|
        if presence_hash[domain_block.domain]
          items.delete(domain_block.domain)
        else
          @account.unblock_domain!(domain_block.domain)
        end
      end
    end

    items.each do |domain|
      @account.block_domain!(domain)
    end

    AfterAccountDomainBlockWorker.push_bulk(items) do |domain|
      [@account.id, domain]
    end
  end

  def import_relationships!(action, undo_action, overwrite_scope, limit, extra_fields = {})
    local_domain_suffix = "@#{Rails.configuration.x.local_domain}"
    items = @data.take(limit).map { |row| [row['Account address']&.strip&.delete_suffix(local_domain_suffix), Hash[extra_fields.map { |key, field_settings| [key, row[field_settings[:header]]&.strip || field_settings[:default]] }]] }.reject { |(id, _)| id.blank? }

    if @import.overwrite?
      presence_hash = items.each_with_object({}) { |(id, extra), mapping| mapping[id] = [true, extra] }

      overwrite_scope.find_each do |target_account|
        if presence_hash[target_account.acct]
          items.delete(target_account.acct)
          extra = presence_hash[target_account.acct][1]
          Import::RelationshipWorker.perform_async(@account.id, target_account.acct, action, extra.stringify_keys)
        else
          Import::RelationshipWorker.perform_async(@account.id, target_account.acct, undo_action)
        end
      end
    end

    head_items = items.uniq { |acct, _| acct.split('@')[1] }
    tail_items = items - head_items

    Import::RelationshipWorker.push_bulk(head_items + tail_items) do |acct, extra|
      [@account.id, acct, action, extra.stringify_keys]
    end
  end

  def import_bookmarks!
    parse_import_data!(['#uri'])
    items = @data.take(ROWS_PROCESSING_LIMIT).map { |row| row['#uri'].strip }

    if @import.overwrite?
      presence_hash = items.index_with(true)

      @account.bookmarks.find_each do |bookmark|
        if presence_hash[bookmark.status.uri]
          items.delete(bookmark.status.uri)
        else
          bookmark.destroy!
        end
      end
    end

    statuses = items.filter_map do |uri|
      status = ActivityPub::TagManager.instance.uri_to_resource(uri, Status)
      next if status.nil? && ActivityPub::TagManager.instance.local_uri?(uri)

      status || ActivityPub::FetchRemoteStatusService.new.call(uri)
    rescue HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::UnexpectedResponseError
      nil
    rescue StandardError => e
      Rails.logger.warn "Unexpected error when importing bookmark: #{e}"
      nil
    end

    account_ids         = statuses.map(&:account_id)
    preloaded_relations = relations_map_for_account(@account, account_ids)

    statuses.keep_if { |status| StatusPolicy.new(@account, status, preloaded_relations).show? }

    statuses.each do |status|
      @account.bookmarks.find_or_create_by!(account: @account, status: status)
    end
  end

  def parse_import_data!(default_headers)
    data = CSV.parse(import_data, headers: true)
    data = CSV.parse(import_data, headers: default_headers) unless data.headers&.first&.strip&.include?(' ')
    @data = data.reject(&:blank?)
  end

  def import_data
    Paperclip.io_adapters.for(@import.data).read.force_encoding(Encoding::UTF_8)
  end

  def relations_map_for_account(account, account_ids)
    {
      blocking: {},
      blocked_by: Account.blocked_by_map(account_ids, account.id),
      muting: {},
      following: Account.following_map(account_ids, account.id),
      domain_blocking_by_domain: {},
    }
  end
end
