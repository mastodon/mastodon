# frozen_string_literal: true

class AuthorizeFollowController < ApplicationController
  layout 'public'

  before_action :authenticate_user!

  def new
    uri = Addressable::URI.parse(acct_param).normalize

    if uri.path && %w(http https).include?(uri.scheme)
      set_account_from_url
    else
      set_account_from_acct
    end

    render :error if @account.nil?
  end

  def create
    @account = FollowService.new.call(current_account, acct_param).try(:target_account)

    if @account.nil?
      render :error
    else
      redirect_to web_url("accounts/#{@account.id}")
    end
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    render :error
  end

  private

  def set_account_from_url
    @account = FetchRemoteAccountService.new.call(acct_param)
  end

  def set_account_from_acct
    @account = FollowRemoteAccountService.new.call(acct_param)
  end

  def acct_param
    params[:acct].gsub(/\Aacct:/, '')
  end
end
