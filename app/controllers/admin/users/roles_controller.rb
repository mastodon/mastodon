# frozen_string_literal: true

module Admin
  class Users::RolesController < BaseController
    before_action :set_user

    def show
      authorize @user, :change_role?
    end

    def update
      authorize @user, :change_role?

      @user.current_account = current_account

      if @user.update(resource_params)
        log_action :change_role, @user
        redirect_to admin_account_path(@user.account_id), notice: I18n.t('admin.accounts.change_role.changed_msg')
      else
        render :show
      end
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def resource_params
      params
        .expect(user: [:role_id])
    end
  end
end
