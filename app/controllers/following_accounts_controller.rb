# frozen_string_literal: true

class FollowingAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @follows = Follow.where(account: @account).order(id: :desc).page(params[:page]).per(FOLLOW_PER_PAGE).preload(:target_account)
  end
end
