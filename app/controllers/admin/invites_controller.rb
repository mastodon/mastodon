# frozen_string_literal: true

module Admin
  class InvitesController < BaseController
    def index
      authorize :invite, :index?

      @invites = Invite.includes(user: :account).page(params[:page])
      @invite  = Invite.new
    end

    def create
      authorize :invite, :create?

      @invite      = Invite.new(resource_params)
      @invite.user = current_user

      if @invite.save
        redirect_to admin_invites_path
      else
        @invites = Invite.page(params[:page])
        render :index
      end
    end

    def destroy
      @invite = Invite.find(params[:id])
      authorize @invite, :destroy?
      @invite.expire!
      redirect_to admin_invites_path
    end

    private

    def resource_params
      params.require(:invite).permit(:max_uses, :expires_in)
    end
  end
end
