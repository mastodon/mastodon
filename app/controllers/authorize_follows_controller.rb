# frozen_string_literal: true

class AuthorizeFollowsController < ApplicationController
  layout 'public'

  before_action :authenticate_user!

  def show
    @account = located_account || render(:error)
  end

  def create
    @account = follow_attempt.try(:target_account)

    if @account.nil?
      render :error
    else
      render :success
    end
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    render :error
  end

  private

  def follow_attempt
    FollowService.new.call(current_account, acct_without_prefix)
  end

  def located_account
    if acct_param_is_url?
      account_from_remote_fetch
    else
      account_from_remote_follow
    end
  end

  def account_from_remote_fetch
    FetchRemoteAccountService.new.call(acct_without_prefix)
  end

  def account_from_remote_follow
    ResolveRemoteAccountService.new.call(acct_without_prefix)
  end

  def acct_param_is_url?
    parsed_uri.path && %w(http https).include?(parsed_uri.scheme)
  end

  def parsed_uri
    Addressable::URI.parse(acct_without_prefix).normalize
  end

  def acct_without_prefix
    acct_params.gsub(/\Aacct:/, '')
  end

  def acct_params
    params.fetch(:acct, '')
  end
end
