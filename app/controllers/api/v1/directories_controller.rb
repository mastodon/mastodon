# frozen_string_literal: true

class Api::V1::DirectoriesController < Api::BaseController
  before_action :require_enabled!
  before_action :set_accounts

  def show
    cache_if_unauthenticated!
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def require_enabled!
    return not_found unless Setting.profile_directory
  end

  def set_accounts
    with_read_replica do
      @accounts = accounts_scope.offset(params[:offset]).limit(limit_param(DEFAULT_ACCOUNTS_LIMIT))
    end
  end

  def accounts_scope
    Account.discoverable.tap do |scope|
      scope.merge!(account_order_scope)
      scope.merge!(local_account_scope) if local_accounts?
      scope.merge!(account_exclusion_scope) if current_account
      scope.merge!(account_domain_block_scope) if current_account && !local_accounts?
    end
  end

  def local_accounts?
    truthy_param?(:local)
  end

  def account_order_scope
    case params[:order]
    when 'new'
      Account.order(id: :desc)
    when 'active', nil
      Account.by_recent_status
    end
  end

  def local_account_scope
    Account.local
  end

  def account_exclusion_scope
    Account.not_excluded_by_account(current_account)
  end

  def account_domain_block_scope
    Account.not_domain_blocked_by_account(current_account)
  end
end
