# frozen_string_literal: true

class StatusReachFinder
  # @param [Status] status
  # @param [Hash] options
  # @option options [Boolean] :unsafe
  def initialize(status, options = {})
    @status  = status
    @options = options
  end

  def inboxes
    (reached_account_inboxes + followers_inboxes + relay_inboxes).uniq
  end

  private

  def reached_account_inboxes
    scope = Account.where(id: reached_account_ids)
    inboxes_without_suspended_for(scope)
  end

  def reached_account_ids
    # When the status is a reblog, there are no interactions with it
    # directly, we assume all interactions are with the original one

    if @status.reblog?
      [reblog_of_account_id]
    else
      [
        replied_to_account_id,
        reblog_of_account_id,
        quote_of_account_id,
        mentioned_account_ids,
        reblogs_account_ids,
        quotes_account_ids,
        favourites_account_ids,
        replies_account_ids,
      ].tap do |arr|
        arr.flatten!
        arr.compact!
        arr.uniq!
      end
    end
  end

  def replied_to_account_id
    @status.in_reply_to_account_id if distributable?
  end

  def quote_of_account_id
    @status.quote&.quoted_account_id
  end

  def reblog_of_account_id
    @status.reblog.account_id if @status.reblog?
  end

  def mentioned_account_ids
    @status.mentions.pluck(:account_id)
  end

  # Beware: Quotes can be created without the author having had access to the status
  def quotes_account_ids
    @status.quotes.pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Reblogs can be created without the author having had access to the status
  def reblogs_account_ids
    @status.reblogs.rewhere(deleted_at: [nil, @status.deleted_at]).pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Favourites can be created without the author having had access to the status
  def favourites_account_ids
    @status.favourites.pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Replies can be created without the author having had access to the status
  def replies_account_ids
    @status.replies.pluck(:account_id) if distributable? || unsafe?
  end

  def followers_inboxes
    scope = followers_scope
    inboxes_without_suspended_for(scope)
  end

  def relay_inboxes
    if @status.public_visibility?
      Relay.enabled.pluck(:inbox_url)
    else
      []
    end
  end

  def distributable?
    @status.public_visibility? || @status.unlisted_visibility?
  end

  def unsafe?
    @options[:unsafe]
  end

  def followers_scope
    if @status.in_reply_to_local_account? && distributable?
      @status.account.followers.or(@status.thread.account.followers.not_domain_blocked_by_account(@status.account))
    elsif @status.direct_visibility? || @status.limited_visibility?
      Account.none
    else
      @status.account.followers
    end
  end

  def inboxes_without_suspended_for(scope)
    scope.merge!(Account.without_suspended) unless unsafe?
    scope.inboxes
  end
end
