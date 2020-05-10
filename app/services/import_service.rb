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
    end
  end

  private

  def import_follows!
    parse_import_data!(['Account address'])
    import_relationships!('follow', 'unfollow', @account.following, follow_limit, reblogs: 'Show boosts')
  end

  def import_blocks!
    parse_import_data!(['Account address'])
    import_relationships!('block', 'unblock', @account.blocking, ROWS_PROCESSING_LIMIT)
  end

  def import_mutes!
    parse_import_data!(['Account address'])
    import_relationships!('mute', 'unmute', @account.muting, ROWS_PROCESSING_LIMIT, notifications: 'Hide notifications')
  end

  def import_domain_blocks!
    parse_import_data!(['#domain'])
    items = @data.take(ROWS_PROCESSING_LIMIT).map { |row| row['#domain'].strip }

    if @import.overwrite?
      presence_hash = items.each_with_object({}) { |id, mapping| mapping[id] = true }

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
    items = @data.take(limit).map { |row| [row['Account address']&.strip&.delete_suffix(local_domain_suffix), Hash[extra_fields.map { |key, header| [key, row[header]&.strip] }]] }.reject { |(id, _)| id.blank? }

    if @import.overwrite?
      presence_hash = items.each_with_object({}) { |(id, extra), mapping| mapping[id] = [true, extra] }

      overwrite_scope.find_each do |target_account|
        if presence_hash[target_account.acct]
          items.delete(target_account.acct)
          extra = presence_hash[target_account.acct][1]
          Import::RelationshipWorker.perform_async(@account.id, target_account.acct, action, extra)
        else
          Import::RelationshipWorker.perform_async(@account.id, target_account.acct, undo_action)
        end
      end
    end

    Import::RelationshipWorker.push_bulk(items) do |acct, extra|
      [@account.id, acct, action, extra]
    end
  end

  def parse_import_data!(default_headers)
    data = CSV.parse(import_data, headers: true)
    data = CSV.parse(import_data, headers: default_headers) unless data.headers&.first&.strip&.include?(' ')
    @data = data.reject(&:blank?)
  end

  def import_data
    Paperclip.io_adapters.for(@import.data).read
  end

  def follow_limit
    FollowLimitValidator.limit_for_account(@account)
  end
end
