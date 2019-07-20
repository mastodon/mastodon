# frozen_string_literal: true

class RemoteFollowController < ApplicationController
  include AccountOwnedConcern

  layout 'modal'

  before_action :set_pack
  before_action :set_body_classes

  def new
    @remote_follow = RemoteFollow.new(session_params)
  end

  def create
    @remote_follow = RemoteFollow.new(resource_params)

    if @remote_follow.valid?
      session[:remote_follow] = @remote_follow.acct
      redirect_to @remote_follow.subscribe_address_for(@account)
    else
      render :new
    end
  end

  private

  def resource_params
    params.require(:remote_follow).permit(:acct)
  end

  def session_params
    { acct: session[:remote_follow] }
  end

  def set_pack
    use_pack 'modal'
  end

  def set_body_classes
    @body_classes = 'modal-layout'
    @hide_header  = true
  end
end
