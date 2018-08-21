# frozen_string_literal: true

class ActivityPub::Activity::Undo < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Announce'
      undo_announce
    when 'Accept'
      undo_accept
    when 'Follow'
      undo_follow
    when 'Like'
      undo_like
    when 'Block'
      undo_block
    end
  end

  private

  def undo_announce
    status   = Status.find_by(uri: object_uri, account: @account)
    status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

    if status.nil?
      delete_later!(object_uri)
    else
      RemoveStatusService.new.call(status)
    end
  end

  def undo_accept
    ::Follow.find_by(target_account: @account, uri: target_uri)&.revoke_request!
  end

  def undo_follow
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    if @account.following?(target_account)
      @account.unfollow!(target_account)
    elsif @account.requested?(target_account)
      FollowRequest.find_by(account: @account, target_account: target_account)&.destroy
    else
      delete_later!(object_uri)
    end
  end

  def undo_like
    status = status_from_uri(target_uri)

    return if status.nil? || !status.account.local?

    if @account.favourited?(status)
      favourite = status.favourites.where(account: @account).first
      favourite&.destroy
    else
      delete_later!(object_uri)
    end
  end

  def undo_block
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    if @account.blocking?(target_account)
      UnblockService.new.call(@account, target_account)
    else
      delete_later!(object_uri)
    end
  end

  def target_uri
    @target_uri ||= value_or_id(@object['object'])
  end
end
