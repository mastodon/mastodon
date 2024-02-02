# frozen_string_literal: true

class CrutchBuilder
  attr_reader :receiver_id, :statuses

  def initialize(receiver_id, statuses)
    @receiver_id = receiver_id
    @statuses = statuses
  end

  def crutches
    crutches = {}

    crutches[:active_mentions] = crutches_active_mentions
    crutches[:following]            = Follow.where(account_id: receiver_id, target_account_id: statuses.filter_map(&:in_reply_to_account_id)).pluck(:target_account_id).index_with(true)
    crutches[:languages]            = Follow.where(account_id: receiver_id, target_account_id: statuses.map(&:account_id)).pluck(:target_account_id, :languages).to_h
    crutches[:hiding_reblogs]       = Follow.where(account_id: receiver_id, target_account_id: statuses.filter_map { |s| s.account_id if s.reblog? }, show_reblogs: false).pluck(:target_account_id).index_with(true)
    crutches[:blocking]             = Block.where(account_id: receiver_id, target_account_id: blocked_statuses_from_mentions).pluck(:target_account_id).index_with(true)
    crutches[:muting]               = Mute.where(account_id: receiver_id, target_account_id: blocked_statuses_from_mentions).pluck(:target_account_id).index_with(true)
    crutches[:domain_blocking]      = AccountDomainBlock.where(account_id: receiver_id, domain: statuses.flat_map { |s| [s.account.domain, s.reblog&.account&.domain] }.compact).pluck(:domain).index_with(true)
    crutches[:blocked_by]           = Block.where(target_account_id: receiver_id, account_id: statuses.map { |s| [s.account_id, s.reblog&.account_id] }.flatten.compact).pluck(:account_id).index_with(true)
    crutches[:exclusive_list_users] = ListAccount.where(list: exclusive_lists, account_id: statuses.map(&:account_id)).pluck(:account_id).index_with(true)

    crutches
  end

  private

  def crutches_active_mentions
    Mention
      .active
      .where(status_id: statuses.flat_map { |status| [status.id, status.reblog_of_id] }.compact)
      .pluck(:status_id, :account_id)
      .each_with_object({}) { |(id, account_id), mapping| (mapping[id] ||= []).push(account_id) }
  end

  def exclusive_lists
    List.where(account_id: receiver_id, exclusive: true)
  end

  def blocked_statuses_from_mentions
    statuses.flat_map do |status|
      (crutches_active_mentions[status.id] || []).tap do |array|
        array.push(status.account_id)

        if status.reblog?
          array.push(status.reblog.account_id)
          array.concat(crutches_active_mentions[status.reblog_of_id] || [])
        end
      end
    end
  end
end
