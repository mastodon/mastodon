# frozen_string_literal: true

class InvitesController < ApplicationController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!
  before_action :set_cache_headers

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
    params.require(:invite).permit(:max_uses, :expires_in, :autofollow, :comment)
  end

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
