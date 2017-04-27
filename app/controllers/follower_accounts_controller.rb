# frozen_string_literal: true

class FollowerAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @accounts = ordered_accounts.page(params[:page]).per(FOLLOW_PER_PAGE)
  end

  private

  def ordered_accounts
    @account.followers.order('follows.created_at desc')
  end
end
