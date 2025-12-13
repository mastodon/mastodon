# frozen_string_literal: true

module Admin
  class InvitesController < BaseController
    def index
      authorize :invite, :index?

      @invites = filtered_invites.includes(user: :account).page(params[:page])
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

    def deactivate_all
      authorize :invite, :deactivate_all?
      Invite.available.in_batches.touch_all(:expires_at)
      redirect_to admin_invites_path
    end

    private

    def resource_params
      params
        .expect(invite: [:max_uses, :expires_in])
    end

    def filtered_invites
      InviteFilter.new(filter_params).results
    end

    def filter_params
      params.slice(*InviteFilter::KEYS).permit(*InviteFilter::KEYS)
    end
  end
end
