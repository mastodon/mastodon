# frozen_string_literal: true

class ActivityPub::Forwarder
  def initialize(account, original_json, status)
    @json    = original_json
    @account = account
    @status  = status
  end

  def forwardable?
    @json['signature'].present? && @status.distributable?
  end

  def forward!
    ActivityPub::LowPriorityDeliveryWorker.push_bulk(inboxes, limit: 1_000) do |inbox_url|
      [payload, signature_account_id, inbox_url]
    end
  end

  private

  def payload
    @payload ||= Oj.dump(@json)
  end

  def reblogged_by_account_ids
    @reblogged_by_account_ids ||= @status.reblogs.includes(:account).references(:account).merge(Account.local).pluck(:account_id)
  end

  def quoted_by_account_ids
    @quoted_by_account_ids ||= @status.quotes.includes(:account).references(:account).merge(Account.local).pluck(:account_id)
  end

  def shared_by_account_ids
    reblogged_by_account_ids.concat(quoted_by_account_ids)
  end

  def signature_account_id
    @signature_account_id ||= if in_reply_to_local?
                                in_reply_to.account_id
                              else
                                shared_by_account_ids.first
                              end
  end

  def inboxes
    @inboxes ||= begin
      arr  = inboxes_for_followers_of_shared_by_accounts
      arr += inboxes_for_followers_of_replied_to_account if in_reply_to_local?
      arr -= [@account.preferred_inbox_url]
      arr.uniq!
      arr
    end
  end

  def inboxes_for_followers_of_shared_by_accounts
    Account.where(id: ::Follow.where(target_account_id: shared_by_account_ids).select(:account_id)).inboxes
  end

  def inboxes_for_followers_of_replied_to_account
    in_reply_to.account.followers.inboxes
  end

  def in_reply_to
    @status.thread
  end

  def in_reply_to_local?
    @status.thread&.account&.local?
  end
end
