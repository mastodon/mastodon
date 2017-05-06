# frozen_string_literal: true

class FollowerAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @follows = Follow.where(target_account: @account).order(id: :desc).page(params[:page]).per(FOLLOW_PER_PAGE).preload(:account)
  end
end
