# frozen_string_literal: true

class UpdateAccountService < BaseService
  def call(account, params, raise_error: false)
    was_locked = account.locked
    update_method = raise_error ? :update! : :update
    if params[:subaction] == 'clear_avatar'
      params = {
        avatar: nil,
        avatar_remote_url: '',
      }
    elsif params[:subaction] == 'clear_header'
      params = {
        header: nil,
        header_remote_url: '',
      }
    end
    account.send(update_method, params).tap do |ret|
      next unless ret
      authorize_all_follow_requests(account) if was_locked && !account.locked
    end
  end

  private

  def authorize_all_follow_requests(account)
    follow_requests = FollowRequest.where(target_account: account)
    AuthorizeFollowWorker.push_bulk(follow_requests) do |req|
      [req.account_id, req.target_account_id]
    end
  end
end
