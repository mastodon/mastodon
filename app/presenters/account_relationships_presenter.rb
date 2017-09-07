# frozen_string_literal: true

class AccountRelationshipsPresenter
  attr_reader :following, :followed_by, :blocking,
              :muting, :requested, :domain_blocking

  def initialize(account_ids, current_account_id, options = {})
    @following       = Account.following_map(account_ids, current_account_id).merge(options[:following_map] || {})
    @followed_by     = Account.followed_by_map(account_ids, current_account_id).merge(options[:followed_by_map] || {})
    @blocking        = Account.blocking_map(account_ids, current_account_id).merge(options[:blocking_map] || {})
    @muting          = Account.muting_map(account_ids, current_account_id).merge(options[:muting_map] || {})
    @requested       = Account.requested_map(account_ids, current_account_id).merge(options[:requested_map] || {})
    @domain_blocking = Account.domain_blocking_map(account_ids, current_account_id).merge(options[:domain_blocking_map] || {})
  end
end
