# frozen_string_literal: true

class AccountFollowController < ApplicationController
  include AccountControllerConcern

  before_action :authenticate_user!

  def create
    FollowService.new.call(current_user.account, @account, with_rate_limit: true)
    redirect_to account_path(@account)
  end
end
