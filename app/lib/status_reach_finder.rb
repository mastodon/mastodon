# frozen_string_literal: true

class StatusReachFinder
  def initialize(status)
    @status = status
  end

  def inboxes
    Account.where(id: reached_account_ids).inboxes
  end

  private

  def reached_account_ids
    [
      replied_to_account_id,
      reblog_of_account_id,
      mentioned_account_ids,
      reblogs_account_ids,
      favourites_account_ids,
      replies_account_ids,
    ].tap do |arr|
      arr.flatten!
      arr.compact!
      arr.uniq!
    end
  end

  def replied_to_account_id
    @status.in_reply_to_account_id
  end

  def reblog_of_account_id
    @status.reblog.account_id if @status.reblog?
  end

  def mentioned_account_ids
    @status.mentions.pluck(:account_id)
  end

  def reblogs_account_ids
    @status.reblogs.pluck(:account_id)
  end

  def favourites_account_ids
    @status.favourites.pluck(:account_id)
  end

  def replies_account_ids
    @status.replies.pluck(:account_id)
  end
end
