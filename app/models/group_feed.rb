# frozen_string_literal: true

class GroupFeed
  # @params [Group] group
  # @param [Account] account
  def initialize(group, account)
    @group = group
    @account = account
  end

  # @param [Integer] limit
  # @param [Integer] max_id
  # @param [Integer] since_id
  # @param [Integer] min_id
  # @return [Array<Status>]
  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    scope = group_scope

    scope.merge!(account_filters_scope) if account?
    scope.merge!(approval_scope)

    scope.cache_ids.to_a_paginated_by_id(limit, max_id: max_id, since_id: since_id, min_id: min_id)
  end

  private

  attr_reader :group, :account

  def account?
    account.present?
  end

  def group_scope
    Status.where(group_id: @group.id).joins(:account).merge(Account.without_suspended.without_silenced)
  end

  def account_filters_scope
    Status.not_excluded_by_account(account).tap do |scope|
      scope.merge!(Status.not_domain_blocked_by_account(account))
    end
  end

  def approval_scope
    scope = Status.approved
    scope = scope.or(Status.where(account: account)) if account?
    scope
  end
end
