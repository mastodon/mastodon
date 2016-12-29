# frozen_string_literal: true

class AuthorizeFollowController < ApplicationController
  layout 'public'

  before_action :authenticate_user!

  def new
    @account = FollowRemoteAccountService.new.call(params[:acct])
    render :error if @account.nil?
  end

  def create
    @account = FollowService.new.call(current_account, params[:acct]).try(:target_account)

    if @account.nil?
      render :error
    else
      redirect_to web_url("accounts/#{@account.id}")
    end
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermitted
    render :error
  end
end
