# frozen_string_literal: true

class InvitesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def index
    @invites = Invite.where(user: current_user)
    @invite  = Invite.new
  end

  def create
    @invite      = Invite.new(resource_params)
    @invite.user = current_user

    if @invite.save
      redirect_to invites_path
    else
      @invites = Invite.where(user: current_user)
      render :index
    end
  end

  private

  def resource_params
    params.require(:invite).permit(:max_uses, :expires_in)
  end
end
