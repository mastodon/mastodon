# frozen_string_literal: true

class UpdateAccountService < BaseService
  include ProfileChangeNotifier

  def call(account, params, raise_error: false)
    was_locked = account.locked
    update_method = raise_error ? :update! : :update

    if params['display_name'] != account.display_name || !params['avatar'].nil?
      prepare_profile_change(account)
    end

    res = account.send(update_method, params).tap do |ret|
      next unless ret
      authorize_all_follow_requests(account) if was_locked && !account.locked
    end

    notify_profile_change

    res
  end

  private

  def authorize_all_follow_requests(account)
    follow_requests = FollowRequest.where(target_account: account)
    AuthorizeFollowWorker.push_bulk(follow_requests) do |req|
      [req.account_id, req.target_account_id]
    end
  end
end
