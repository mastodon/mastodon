# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @users = User.all.page(params[:page])
    end

    def show
    end
  end
end
