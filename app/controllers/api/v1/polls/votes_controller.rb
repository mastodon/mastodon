# frozen_string_literal: true

class Api::V1::Polls::VotesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }
  before_action :require_user!
  before_action :set_poll

  def create
    VoteService.new.call(current_account, @poll, vote_params[:choices])
    render json: @poll, serializer: REST::PollSerializer
  end

  private

  def set_poll
    @poll = Poll.attached.find(params[:poll_id])
    authorize @poll.status, :show?
  rescue Mastodon::NotPermittedError
    raise ActiveRecord::RecordNotFound
  end

  def vote_params
    params.permit(choices: [])
  end
end
