# frozen_string_literal: true

module Admin
  class FollowersController < BaseController
    before_action :set_account

    PER_PAGE = 40

    def index
      authorize :account, :index?
      @followers = @account.followers.local.recent.page(params[:page]).per(PER_PAGE)
    end

    def set_account
      @account = Account.find(params[:account_id])
    end
  end
end
