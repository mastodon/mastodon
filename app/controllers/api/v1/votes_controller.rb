# frozen_string_literal: true
class Api::V1::VotesController < Api::BaseController
  include Authorization

  before_action :authorize_if_got_token, except:            [:create]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create]
  before_action :require_user!

  respond_to :json

  def create
    status_id = params[:status_id]
    status =  Status.find(status_id)
    enquete_info = status && JSON.parse(status.enquete)
    unless enquete_info
      render json: { 'valid': false, 'message': 'not found' }
      return
    end

    voted = redis.get("enquete:status:#{status_id}:account:#{current_account.id}")
    unless voted.nil?
      render json: { 'valid': false, 'message': 'already voted' }
      return
    end

    item_index = vote_params[:item_index].to_i
    if item_index >= enquete_info['items'].size
      render json: { 'valid': false, 'message': 'wrong vote number' }
      return
    end

    redis.multi do |multi|
      # Add voted info
      remaining_time = (status.created_at.to_i + enquete_info['duration']) - Time.zone.now.to_i + 60
      multi.setex("enquete:status:#{status_id}:account:#{current_account.id}", remaining_time, item_index)
      # Increment number of votes
      multi.incr("enquete:status:#{status_id}:item_index:#{item_index}")
    end

    render json: { 'valid': true, 'message': 'OK' }
  end

  private

  def vote_params
    params.permit(:item_index)
  end

  def redis
    Redis.current
  end
end
