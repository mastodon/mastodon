# frozen_string_literal: true

class Api::V1::PollsController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, only: :show

  respond_to :json

  def show
    @poll = Poll.attached.find(params[:id])
    ActivityPub::FetchRemotePollService.new.call(@poll, current_account) if user_signed_in? && @poll.possibly_stale?
    render json: @poll, serializer: REST::PollSerializer, include_results: true
  end
end
