# frozen_string_literal: true

class FollowRequestsController < ApplicationController
  layout 'auth'

  before_action :authenticate_user!
  before_action :set_follow_request, except: :index

  def index
    @follow_requests = FollowRequest.where(target_account: current_account)
  end

  def authorize
    @follow_request.authorize!
    redirect_to follow_requests_path
  end

  def reject
    @follow_request.reject!
    redirect_to follow_requests_path
  end

  private

  def set_follow_request
    @follow_request = FollowRequest.find(params[:id])
  end
end
