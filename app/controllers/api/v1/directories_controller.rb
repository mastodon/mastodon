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
    @accounts = accounts_scope.offset(params[:offset]).limit(limit_param(DEFAULT_ACCOUNTS_LIMIT))
  end

  def accounts_scope
    Account.discoverable.tap do |scope|
      scope.merge!(Account.local)                                          if truthy_param?(:local)
      scope.merge!(Account.by_recent_status)                               if params[:order].blank? || params[:order] == 'active'
      scope.merge!(Account.order(id: :desc))                               if params[:order] == 'new'
      scope.merge!(Account.not_excluded_by_account(current_account))       if current_account
      scope.merge!(Account.not_domain_blocked_by_account(current_account)) if current_account && !truthy_param?(:local)
    end
  end
end
