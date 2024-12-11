# frozen_string_literal: true

class Api::V1::Lists::FollowsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:follows' }
  before_action :require_user!
  before_action :set_list

  def create
    FollowFromPublicListWorker.perform_async(current_account.id, @list.id)
    render json: {}, status: 202
  end

  private

  def set_list
    @list = List.where(type: :public_list).find(params[:list_id])
  end
end
