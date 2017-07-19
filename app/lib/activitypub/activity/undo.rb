# frozen_string_literal: true

class ActivityPub::Activity::Undo < ActivityPub::Activity
  def perform
    case @object['type']
    when 'Announce'
      undo_announce
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
    status = Status.find_by(uri: object_uri, account: @account)
    RemoveStatusService.new.call(status) unless status.nil?
  end

  def undo_follow
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    @account.unfollow!(target_account)
  end

  def undo_like
    status = status_from_uri(target_uri)

    return if status.nil? || !status.account.local?

    favourite = status.favourites.where(account: @account).first
    favourite&.destroy
  end

  def undo_block
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    UnblockService.new.call(@account, target_account)
  end

  def target_uri
    @target_uri ||= @object['object'].is_a?(String) ? @object['object'] : @object['object']['id']
  end
end
