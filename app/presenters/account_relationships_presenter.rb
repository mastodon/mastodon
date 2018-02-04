# frozen_string_literal: true

class AccountRelationshipsPresenter
  attr_reader :following, :followed_by, :blocking,
              :muting, :requested, :domain_blocking

  def initialize(account_ids, current_account_id)
    @following       = Account.following_map(account_ids, current_account_id)
    @followed_by     = Account.followed_by_map(account_ids, current_account_id)
    @blocking        = Account.blocking_map(account_ids, current_account_id)
    @muting          = Account.muting_map(account_ids, current_account_id)
    @requested       = Account.requested_map(account_ids, current_account_id)
    @domain_blocking = Account.domain_blocking_map(account_ids, current_account_id)
  end
end
