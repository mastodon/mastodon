# frozen_string_literal: true

class CrutchBuilder
  attr_reader :receiver_id, :statuses

  def initialize(receiver_id, statuses)
    @receiver_id = receiver_id
    @statuses = statuses
  end

  def crutches
    {}.tap do |crutches|
      crutches[:active_mentions] = crutches_active_mentions
      crutches[:following] = following_index
      crutches[:languages] = languages_index
      crutches[:hiding_reblogs] = hiding_reblogs_index
      crutches[:blocking] = blocking_index
      crutches[:muting] = muting_index
      crutches[:domain_blocking] = domain_blocking_index
      crutches[:blocked_by] = blocked_by_index
      crutches[:exclusive_list_users] = exclusive_list_users_index
    end
  end

  private

  def crutches_active_mentions
    Mention
      .active
      .where(status_id: statuses_primary_and_reblog_ids)
      .pluck(:status_id, :account_id)
      .each_with_object({}) { |(id, account_id), mapping| (mapping[id] ||= []).push(account_id) }
  end

  def following_index
    Follow
      .where(account_id: receiver_id, target_account_id: statuses_reply_to_account_ids)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def languages_index
    Follow
      .where(account_id: receiver_id, target_account_id: statuses_account_ids)
      .pluck(:target_account_id, :languages)
      .to_h
  end

  def hiding_reblogs_index
    Follow
      .where(account_id: receiver_id, target_account_id: statuses_reblog_account_ids, show_reblogs: false)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def blocking_index
    Block
      .where(account_id: receiver_id, target_account_id: blocked_statuses_from_mentions)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def muting_index
    Mute
      .where(account_id: receiver_id, target_account_id: blocked_statuses_from_mentions)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def domain_blocking_index
    AccountDomainBlock
      .where(account_id: receiver_id, domain: statuses_account_domains)
      .pluck(:domain)
      .index_with(true)
  end

  def blocked_by_index
    Block
      .where(target_account_id: receiver_id, account_id: statuses_and_reblogs_account_ids)
      .pluck(:account_id)
      .index_with(true)
  end

  def exclusive_list_users_index
    ListAccount
      .where(list: exclusive_lists, account_id: statuses_account_ids)
      .pluck(:account_id)
      .index_with(true)
  end

  def exclusive_lists
    List
      .where(account_id: receiver_id, exclusive: true)
  end

  def statuses_account_ids
    statuses
      .map(&:account_id)
  end

  def statuses_reply_to_account_ids
    statuses
      .filter_map(&:in_reply_to_account_id)
  end

  def statuses_reblog_account_ids
    statuses
      .filter_map { |status| status.account_id if status.reblog? }
  end

  def statuses_account_domains
    statuses
      .flat_map { |status| [status.account.domain, status.reblog&.account&.domain] }
      .compact
  end

  def statuses_and_reblogs_account_ids
    statuses
      .map { |status| [status.account_id, status.reblog&.account_id] }
      .flatten
      .compact
  end

  def statuses_primary_and_reblog_ids
    statuses
      .flat_map { |status| [status.id, status.reblog_of_id] }
      .compact
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
