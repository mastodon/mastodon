# frozen_string_literal: true

class StatusReachFinder
  DEFAULT_OPTIONS = {
    with_parent: true,
  }.freeze

  # @param [Status] status
  # @param [Hash] options
  # @option [Boolean] with_parent
  def initialize(status, options = {})
    @status  = status
    @options = DEFAULT_OPTIONS.merge(options)
  end

  # @return [Array<String>]
  def inboxes
    (reached_account_inboxes + followers_inboxes + relay_inboxes).uniq
  end

  private

  def reached_account_inboxes
    # When the status is a reblog, there are no interactions with it
    # directly, we assume all interactions are with the original one

    return [] if @status.reblog?

    # If a status is a reply to a local status, we also want to send
    # it everywhere the parent status was sent

    arr = []
    arr.concat(self.class.new(@status.thread, with_parent: false).inboxes) if @status.in_reply_to_local_account? && @options[:with_parent]
    arr.concat(Account.where(id: reached_account_ids).inboxes)
    arr
  end

  def reached_account_ids
    [
      replied_to_account_id,
      reblog_of_account_id,
      mentioned_account_ids,
      reblogs_account_ids,
      reblogger_follower_account_ids,
      favourites_account_ids,
      replies_account_ids,
    ].tap do |arr|
      arr.flatten!
      arr.compact!
      arr.uniq!
    end
  end

  def replied_to_account_id
    @status.in_reply_to_account_id if @status.local?
  end

  def reblog_of_account_id
    @status.reblog.account_id if @status.reblog?
  end

  def mentioned_account_ids
    @status.mentions.pluck(:account_id) if @status.local?
  end

  def reblogs_account_ids
    @reblogs_account_ids ||= @status.reblogs.pluck(:account_id)
  end

  def reblogger_follower_account_ids
    Follow.where(target_account_id: reblogs_account_ids).pluck(:account_id)
  end

  def favourites_account_ids
    @status.favourites.pluck(:account_id) if @status.local?
  end

  def replies_account_ids
    @status.replies.pluck(:account_id) if @status.local?
  end

  def followers_inboxes
    @status.account.followers.inboxes
  end

  def relay_inboxes
    if @status.public_visibility?
      Relay.enabled.pluck(:inbox_url)
    else
      []
    end
  end
end
