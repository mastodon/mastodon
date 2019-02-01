# frozen_string_literal: true

require 'csv'

class ImportService < BaseService
  ROWS_PROCESSING_LIMIT = 20_000

  def call(import)
    @import  = import
    @account = @import.account
    @data    = CSV.new(import_data).reject(&:blank?)

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
    import_relationships!('follow', 'unfollow', @account.following, follow_limit)
  end

  def import_blocks!
    import_relationships!('block', 'unblock', @account.blocking, ROWS_PROCESSING_LIMIT)
  end

  def import_mutes!
    import_relationships!('mute', 'unmute', @account.muting, ROWS_PROCESSING_LIMIT)
  end

  def import_domain_blocks!
    items = @data.take(ROWS_PROCESSING_LIMIT).map { |row| row.first.strip }

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

  def import_relationships!(action, undo_action, overwrite_scope, limit)
    items = @data.take(limit).map { |row| row.first.strip }

    if @import.overwrite?
      presence_hash = items.each_with_object({}) { |id, mapping| mapping[id] = true }

      overwrite_scope.find_each do |target_account|
        if presence_hash[target_account.acct]
          items.delete(target_account.acct)
        else
          Import::RelationshipWorker.perform_async(@account.id, target_account.acct, undo_action)
        end
      end
    end

    Import::RelationshipWorker.push_bulk(items) do |acct|
      [@account.id, acct, action]
    end
  end

  def import_data
    Paperclip.io_adapters.for(@import.data).read
  end

  def follow_limit
    FollowLimitValidator.limit_for_account(@account)
  end
end
