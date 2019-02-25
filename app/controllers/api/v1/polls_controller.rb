# frozen_string_literal: true

class Api::V1::PollsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only: :create
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, only: :show
  before_action :require_user!

  respond_to :json

  def create
    @poll = current_account.polls.create!(poll_params)
    render json: @poll, serializer: REST::PollSerializer
  end

  def show
    @poll = Poll.attached.find(params[:id])
    ActivityPub::FetchRemotePollService.new.call(@poll, current_account) if @poll.possibly_stale?
    render json: @poll, serializer: REST::PollSerializer, include_results: true
  end

  private

  def poll_params
    params.permit(:options, :multiple, :hide_totals, :expires_at)
  end
end
