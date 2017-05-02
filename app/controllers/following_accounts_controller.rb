# frozen_string_literal: true

class FollowingAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @accounts = @account.following.page(params[:page]).per(FOLLOW_PER_PAGE)
  end
end
