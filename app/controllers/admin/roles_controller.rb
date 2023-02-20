# frozen_string_literal: true

module Admin
  class RolesController < BaseController
    before_action :set_role, except: %i(index new create)

    def index
      authorize :user_role, :index?

      @roles = UserRole.order(position: :desc).page(params[:page])
    end

    def new
      authorize :user_role, :create?

      @role = UserRole.new
    end

    def create
      authorize :user_role, :create?

      @role = UserRole.new(resource_params)
      @role.current_account = current_account

      if @role.save
        log_action :create, @role
        redirect_to admin_roles_path
      else
        render :new
      end
    end

    def edit
      authorize @role, :update?
    end

    def update
      authorize @role, :update?

      @role.current_account = current_account

      if @role.update(resource_params)
        log_action :update, @role
        redirect_to admin_roles_path
      else
        render :edit
      end
    end

    def destroy
      authorize @role, :destroy?
      @role.destroy!
      log_action :destroy, @role
      redirect_to admin_roles_path
    end

    private

    def set_role
      @role = UserRole.find(params[:id])
    end

    def resource_params
      params.require(:user_role).permit(:name, :color, :highlighted, :position, permissions_as_keys: [])
    end
  end
end
