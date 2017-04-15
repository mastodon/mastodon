# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @users = filtered_users.page(params[:page])
    end

    def show
      @user = User.find(params[:id])
    end

    private

    def filtered_users
      UserFilter.new(filter_params).results
    end

    def filter_params
      params.permit(
        :admin,
        :confirmed,
        :unconfirmed
      )
    end
  end
end
