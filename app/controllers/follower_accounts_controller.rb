# frozen_string_literal: true

class FollowerAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @accounts = @account.followers.page(params[:page]).per(FOLLOW_PER_PAGE)
  end
end
