# frozen_string_literal: true

class FollowingAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @accounts = ordered_accounts.page(params[:page]).per(FOLLOW_PER_PAGE)
  end

  private

  def ordered_accounts
    @account.following.order('follows.created_at desc')
  end
end
