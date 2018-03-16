# frozen_string_literal: true

class InvitesController < ApplicationController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!

  def index
    authorize :invite, :create?

    @invites = Invite.where(user: current_user)
    @invite  = Invite.new(expires_in: 1.day.to_i)
  end

  def create
    authorize :invite, :create?

    @invite      = Invite.new(resource_params)
    @invite.user = current_user

    if @invite.save
      redirect_to invites_path
    else
      @invites = Invite.where(user: current_user)
      render :index
    end
  end

  def destroy
    @invite = Invite.where(user: current_user).find(params[:id])
    authorize @invite, :destroy?
    @invite.expire!
    redirect_to invites_path
  end

  private

  def resource_params
    params.require(:invite).permit(:max_uses, :expires_in)
  end
end
