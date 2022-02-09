# frozen_string_literal: true

class StatusReachFinder
  def initialize(status)
    @status = status
  end

  def inboxes
    (reached_account_inboxes + followers_inboxes + relay_inboxes).uniq
  end

  private

  def reached_account_inboxes
    # When the status is a reblog, there are no interactions with it
    # directly, we assume all interactions are with the original one

    if @status.reblog?
      []
    else
      Account.where(id: reached_account_ids).inboxes
    end
  end

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

  def followers_inboxes
    if @status.in_reply_to_local_account? && @status.distributable?
      @status.account.followers.or(@status.thread.account.followers).inboxes
    else
      @status.account.followers.inboxes
    end
  end

  def relay_inboxes
    if @status.public_visibility?
      Relay.enabled.pluck(:inbox_url)
    else
      []
    end
  end
end
