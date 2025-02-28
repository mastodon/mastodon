# frozen_string_literal: true

class InvitesController < ApplicationController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!

  def index
    authorize :invite, :create?

    @invites = invites
    @invite  = Invite.new
  end

  def create
    authorize :invite, :create?

    @invite      = Invite.new(resource_params)
    @invite.user = current_user

    if @invite.save
      redirect_to invites_path
    else
      @invites = invites
      render :index
    end
  end

  def destroy
    @invite = invites.find(params[:id])
    authorize @invite, :destroy?
    @invite.expire!
    redirect_to invites_path
  end

  private

  def invites
    current_user.invites.order(id: :desc)
  end

  def resource_params
    params.expect(invite: [:max_uses, :expires_in, :autofollow, :comment])
  end
end
